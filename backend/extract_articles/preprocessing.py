import re
from collections import Counter
from urllib.parse import urlparse

# =========================
# REMOVE DUPLICATE PARAGRAPHS
# =========================

def remove_duplicate_paragraphs(paragraphs):
    seen = set()
    unique = []

    for p in paragraphs:

        normalized = p.strip().lower()

        if normalized not in seen:
            seen.add(normalized)
            unique.append(p)
    return unique

# =========================
# CLEAN TEXT
# =========================

def clean_text(text):
    text = re.sub(r'\s+', ' ', text)
    text = text.replace('\xa0', ' ')
    return text.strip()

# =========================
# FILTER BAD PARAGRAPHS
# =========================

def is_valid_paragraph(text):

    bad_keywords = [
        "advertisement",
        "subscribe",
        "cookie",
        "sign up",
        "newsletter",
        "all rights reserved"
    ]

    lower = text.lower()

    for keyword in bad_keywords:

        if keyword in lower:
            return False

    if len(text) < 40:
        return False

    return True

# =========================
# DETECT DIFFICULTY
# =========================

def detect_difficulty(word_count):

    if word_count < 300:
        return "A2"

    elif word_count < 700:
        return "B1"

    elif word_count < 1500:
        return "B2"

    else:
        return "C1"

# =========================
# EXTRACT WORDS
# =========================

def extract_words(content):
    stop_words = {
        "the", "and", "for", "that", "with", "this", "have", "from", 
        "they", "will", "been", "were", "their", "about", "there", 
        "would", "could", "after", "into", "your", "more", "than",
        "which", "when", "where", "who", "whom", "also", "made", "said"
    }

    words = re.findall(r'\b[a-z]{4,}\b', content.lower())

    unique_words = set(word for word in words if len(word) > 2)
    return sorted(list(unique_words))

# =========================
# CATEGORY
# =========================

def detect_category(url, title, content):

    url_path = urlparse(url).path.lower()
    text = f"{title} {content}".lower()

    categories = {

        "Sports": [
            "football",
            "premier league",
            "laliga",
            "bundesliga",
            "serie a",
            "world cup",
            "league 1",
            "coach",
            "goal",
            "player",
            "match",
            "arsenal",
            "chelsea",
            "everton",
            "liverpool",
            "nba",
            "fifa"
        ],

        "Technology": [
            "ai",
            "artificial intelligence",
            "software",
            "iphone",
            "android",
            "google",
            "microsoft",
            "apple",
            "tech"
        ],

        "Business": [
            "stock",
            "market",
            "economy",
            "company",
            "business",
            "finance",
            "investment"
        ],

        "Health": [
            "health",
            "doctor",
            "hospital",
            "covid",
            "medicine",
            "disease"
        ],

        "Entertainment": [
            "movie",
            "music",
            "actor",
            "actress",
            "netflix",
            "show",
            "singer"
        ],

        "Learning": [
            "learn",
            "learning",
            "education",
            "course",
            "study",
            "language"
        ],

        "Animal": [
            "animal",
            "dog",
            "cat",
            "wildlife",
            "zoo",
            "pet"
        ],

        "Travel": [
            "travel",
            "tourism",
            "destination",
        ],

        "History": [
            "history",
            "historical",
            "ancient",
            "medieval",
            "war",
            "empire"
        ],

        "Science": [
            "science",
        ]
    }

    scores = {}

    for category, keywords in categories.items():
        for keyword in keywords:
            if keyword in url_path:
                return category

    scores = {}
    for category, keywords in categories.items():
        score = 0
        for keyword in keywords:
            # Thay thế dấu gạch ngang bằng khoảng trắng khi check trong text
            clean_keyword = keyword.replace("-", " ")
            if clean_keyword in text:
                score += 1
        scores[category] = score

    best_category = max(scores, key=scores.get)

    if scores[best_category] == 0:
        return "General"

    return best_category