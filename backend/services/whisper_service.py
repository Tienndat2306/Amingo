import whisper
import os

# Tải model AI khi khởi động
print("Đang khởi tạo AI Whisper (base)...")
model = whisper.load_model("base")

def generate_subtitles(audio_path):
    if not audio_path or not os.path.exists(audio_path):
        return []

    try:
        # AI "nghe" và trả về kết quả
        result = model.transcribe(audio_path)
        
        subtitles = []
        for segment in result['segments']:
            subtitles.append({
                'start': round(segment['start'], 2),
                'end': round(segment['end'], 2),
                'content': segment['text'].strip()
            })
        return subtitles
    except Exception as e:
        print(f"Lỗi AI Whisper: {e}")
        return []