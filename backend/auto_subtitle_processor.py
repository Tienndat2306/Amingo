import firebase_admin
from firebase_admin import credentials, firestore
from services.youtube_service import download_audio
from services.whisper_service import generate_subtitles
from deep_translator import GoogleTranslator
from google.cloud.firestore_v1.base_query import FieldFilter
import os

# Kết nối Firebase (đảm bảo file json chìa khóa để cùng thư mục này)
base_dir = os.path.dirname(os.path.abspath(__file__))
key_path = os.path.join(base_dir, "extract_articles", "firebase_key.json")
cred = credentials.Certificate(key_path)
firebase_admin.initialize_app(cred)
db = firestore.client()

def start_auto_sub():
    # Tìm video chưa có phụ đề (hoặc vừa được đặt lại thành False)
    videos = db.collection('video_lessons').where(filter=FieldFilter('hasSubtitles', '==', False)).stream()
    
    for doc in videos:
        v = doc.to_dict()
        v_id = doc.id
        print(f"\n--- Đang xử lý: {v.get('title')} ---")
        
        # 🌟 BỔ SUNG: Tự động xóa sạch sub-collection 'subtitles' cũ nếu có trước khi nạp mới
        print("🧹 Đang dọn dẹp phụ đề cũ trên Firestore...")
        sub_ref = db.collection('video_lessons').document(v_id).collection('subtitles')
        old_subs = sub_ref.stream()
        for old_sub in old_subs:
            old_sub.reference.delete()
            
        # 1. Tải nhạc
        path = download_audio(v.get('videoUrl'), v_id)
        
        if path:
            # 2. Chạy AI Whisper để sinh phụ đề tiếng Anh gốc
            subs = generate_subtitles(path)
            
            print(f"-> Đang tiến hành dịch {len(subs)} câu thoại sang tiếng Việt...")
            translator = GoogleTranslator(source='en', target='vi')
            
            # 3. Lưu vào Firebase Sub-collection kèm theo trường dịch tiếng Việt
            for s in subs:
                eng_text = s.get('content', '')
                if eng_text.strip():
                    try:
                        s['vi'] = translator.translate(eng_text)
                    except Exception as translate_err:
                        print(f"⚠️ Lỗi dịch câu '{eng_text}': {translate_err}")
                        s['vi'] = ""
                else:
                    s['vi'] = ""

                # Thêm document mới (đã có trường 'vi') vào sub-collection sạch
                sub_ref.add(s)
            
            # 4. Đánh dấu đã hoàn thành
            db.collection('video_lessons').document(v_id).update({'hasSubtitles': True})
            
            # 5. Xóa file tạm
            os.remove(path)
            print("🎉 Xử lý, dọn dẹp và dịch phụ đề thành công!")

if __name__ == "__main__":
    start_auto_sub()
