from flask import Flask, request, jsonify
from bs4 import BeautifulSoup
import requests

import firebase_admin
from firebase_admin import credentials, firestore

from datetime import datetime
import os

# =========================
# IMPORT PREPROCESSING
# =========================

from preprocessing import (
    clean_text,
    is_valid_paragraph,
    remove_duplicate_paragraphs,
    detect_difficulty,
    extract_words,
    detect_category
)

# =========================
# FIREBASE INIT
# =========================

# Lấy đường dẫn của thư mục hiện tại chứa file app.py
base_dir = os.path.dirname(os.path.abspath(__file__))
# Kết nối đến file json
key_path = os.path.join(base_dir, "firebase_key.json")

cred = credentials.Certificate(key_path)

firebase_admin.initialize_app(cred)

db = firestore.client()

# =========================
# FLASK INIT
# =========================

app = Flask(__name__)

# =========================
# TEST ROUTE
# =========================

@app.route('/')
def home():

    return "Backend is running!"

# =========================
# EXTRACT ARTICLE API
# =========================

@app.route('/extract-article', methods=['POST'])
def extract_article():

    try:

        data = request.get_json()

        url = data.get('url')

        if not url:

            return jsonify({
                "success": False,
                "message": "URL is required"
            }), 400

        # =========================
        # REQUEST WEBSITE
        # =========================

        headers = {
            "User-Agent":
                "Mozilla/5.0"
        }

        response = requests.get(
            url,
            headers=headers,
            timeout=15
        )

        if response.status_code != 200:

            return jsonify({
                "success": False,
                "message": "Failed to fetch article"
            }), 400

        # =========================
        # PARSE HTML
        # =========================

        soup = BeautifulSoup(
            response.text,
            "html.parser"
        )

        # =========================
        # TITLE
        # =========================

        title = (
            soup.title.string.strip()
            if soup.title and soup.title.string
            else "No title"
        )

        title = clean_text(title)

        # =========================
        # CONTENT
        # =========================

        sections = []

        current_section = {
            "heading": "",
            "paragraphs": []
        }

        elements = soup.find_all([
            "h1",
            "h2",
            "h3",
            "p"
        ])

        for element in elements:
            tag = element.name
            text = clean_text(element.get_text().strip())
            if not text:
                continue

            # =========================
            # HEADING
            # =========================

            if tag in ["h2", "h3"]:
                # Lưu section cũ
                if current_section["paragraphs"]:
                    sections.append(current_section)

                # Tạo section mới
                current_section = {
                    "heading": text,
                    "paragraphs": []
                }

            # =========================
            # PARAGRAPH
            # =========================

            elif tag == "p":
                if is_valid_paragraph(text):
                    current_section[ "paragraphs"].append(text)

        # =========================
        # ADD LAST SECTION
        # =========================

        if current_section["paragraphs"]:
            sections.append(current_section)

        # =========================
        # REMOVE DUPLICATES
        # =========================

        paragraphs = []

        for section in sections:
            paragraphs.extend(
                section["paragraphs"]
            )

        paragraphs = remove_duplicate_paragraphs(paragraphs)

        # =========================
        # FINAL CONTENT
        # =========================

        content = "\n\n".join(paragraphs)

        # =========================
        # IMAGE
        # =========================

        image = ""

        og_image = soup.find(
            "meta",
            property="og:image"
        )

        if og_image:
            image = og_image.get(
                "content",
                ""
            )
        # =========================
        # WORD COUNT
        # =========================

        word_count = len(
            content.split()
        )

        # =========================
        # DIFFICULTY
        # =========================

        difficulty = detect_difficulty(
            word_count
        )

        # =========================
        # WORDS
        # =========================

        words = extract_words(
            content
        )

        # =========================
        # CATEGORY
        # =========================

        category = detect_category(
            url,
            title,
            content
        )

        # =========================
        # SAVE FIRESTORE
        # =========================

        doc_ref = db.collection(
            "articles"
        ).document()

        article_data = {

            "title": title,

            "category": category,

            "content": content,

            "sections": sections,

            "paragraphs": paragraphs,

            "words": words,

            "imageUrl": image,

            "originalUrl": url,

            "language": "en",

            "difficulty": difficulty,

            "wordCount": word_count,

            "translatedTitle": "",

            "translatedParagraphs": [],

            "audioUrl": "",

            "createdAt": datetime.now()
        }

        doc_ref.set(article_data)

        # =========================
        # RESPONSE
        # =========================

        return jsonify({
            "articleId": doc_ref.id,

            "title": title,

            "category": category,

            "content": content,

            "sections": sections,

            "paragraphs": paragraphs,

            "imageUrl": image,

            "difficulty": difficulty,

            "wordCount": word_count,

            "words": words
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500

# =========================
# RUN SERVER
# =========================

if __name__ == '__main__':

    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True
    )