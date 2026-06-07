# Amingo

Amingo la ung dung hoc tieng Anh xay dung bang Flutter, ho tro nguoi hoc luyen tu vung, ngu phap, nghe chep chinh ta, hoc qua video co phu de, doc tin tuc/bai viet tieng Anh va luu bai hoc yeu thich. Ung dung co them giao dien quan tri de quan ly noi dung hoc tap.

## Tinh nang chinh

### Nguoi dung

- Dang ky, dang nhap bang email/password
- Dang nhap xa hoi voi Google va Facebook
- Chon ngon ngu hoc
- Hoc tu vung theo bo tu
- Luyen tap bang flashcard, trac nghiem, ghep cap, nghe va chinh ta
- Hoc ngu phap theo chu de
- Lam quiz ngu phap va luu tien do
- Luyen nghe dictation
- Xem video bai hoc YouTube kem phu de
- Doc bai viet/tin tuc tieng Anh
- Luu bai viet, video va tu vung yeu thich
- Quan ly ho so ca nhan

### Admin

- Dashboard thong ke du lieu Firestore
- Quan ly bo tu vung va tu vung
- Quan ly chu de ngu phap va cau hoi quiz
- Quan ly topic/section/lesson nghe
- Quan ly video bai hoc va phu de
- Quan ly bai viet/tin tuc

## Cong nghe su dung

| Nhom | Cong nghe |
|---|---|
| Frontend | Flutter, Dart |
| State Management | Provider |
| Backend-as-a-Service | Firebase Auth, Cloud Firestore, Firebase Storage |
| Social Auth | Google Sign-In, Facebook Auth |
| Media | YouTube Player, Audio Players, Image Picker, File Picker |
| UI | Material 3, Google Fonts |
| Backend phu tro | Python, Flask, BeautifulSoup, requests, firebase_admin, yt_dlp, OpenAI Whisper, deep_translator |
| Database | Cloud Firestore |

## Cau truc thu muc

```text
Amingo/
|-- lib/
|   |-- main.dart
|   |-- firebase_options.dart
|   |-- core/
|   |   |-- constants/
|   |   |-- providers/
|   |   |-- theme/
|   |   |-- utils/
|   |   `-- widgets/
|   |-- data/
|   |   |-- models/
|   |   |-- repositories/
|   |   |-- services/
|   |   `-- mock/
|   `-- features/
|       |-- auth/
|       |-- home/
|       |-- vocabulary/
|       |-- lesson/
|       |-- grammar/
|       |-- listening/
|       |-- video/
|       |-- news/
|       |-- save/
|       |-- profile/
|       |-- language_selection/
|       `-- admin/
|-- backend/
|   |-- extract_articles/
|   |-- services/
|   `-- auto_subtitle_processor.py
|-- assets/
|   |-- logo/
|   `-- audio/
|-- android/
|-- ios/
|-- web/
|-- windows/
|-- macos/
|-- linux/
|-- pubspec.yaml
|-- pubspec.lock
`-- firebase.json
```

## Yeu cau he thong

Truoc khi chay du an, can cai dat:

- Flutter SDK
- Dart SDK `>=3.10.7 <4.0.0`
- Firebase CLI
- Android Studio hoac VS Code
- Python 3 neu muon chay backend phu tro
- Thiet bi gia lap hoac thiet bi that

Kiem tra moi truong Flutter:

```bash
flutter doctor
```

## Cai dat du an

Clone repository:

```bash
git clone https://github.com/your-username/amingo.git
cd amingo
```

Cai dat dependencies Flutter:

```bash
flutter pub get
```

## Cau hinh Firebase

Du an su dung Firebase cho authentication, database va storage.

Can cau hinh cac dich vu sau trong Firebase Console:

- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Google Sign-In
- Facebook Login neu su dung dang nhap Facebook

Sau khi cau hinh Firebase, tao lai file cau hinh:

```bash
flutterfire configure
```

Lenh nay se tao hoac cap nhat file:

```text
lib/firebase_options.dart
```

## Cau hinh bien bi mat

Khong commit cac file chua secret hoac service account key len GitHub.

Nhung file sau can duoc loai khoi Git:

```text
backend/my_key.json
backend/extract_articles/firebase_key.json
```

Nen them vao `.gitignore`:

```gitignore
backend/my_key.json
backend/extract_articles/firebase_key.json
*.env
```

Neu cac key nay da tung duoc commit, can rotate key tren Firebase Console.

## Chay ung dung

Chay tren thiet bi mac dinh:

```bash
flutter run
```

Chay tren Chrome:

```bash
flutter run -d chrome
```

Chay tren Android:

```bash
flutter run -d android
```

## Build ung dung

Build Android APK:

```bash
flutter build apk
```

Build Android App Bundle:

```bash
flutter build appbundle
```

Build Web:

```bash
flutter build web
```

## Backend phu tro

Thu muc `backend/` chua cac script/API Python ho tro xu ly noi dung.

### Extract Article API

File chinh:

```text
backend/extract_articles/app.py
```

Chuc nang:

- Nhan URL bai viet
- Crawl noi dung HTML
- Lam sach van ban
- Phan loai category/difficulty
- Luu bai viet vao Firestore

Chay API:

```bash
cd backend/extract_articles
python app.py
```

### Auto Subtitle Processor

File chinh:

```text
backend/auto_subtitle_processor.py
```

Chuc nang:

- Quet cac video chua co phu de
- Tai audio tu YouTube bang `yt_dlp`
- Tao phu de bang Whisper
- Dich phu de sang tieng Viet
- Luu phu de vao Firestore

Chay script:

```bash
cd backend
python auto_subtitle_processor.py
```

Luu y: hien du an chua co `requirements.txt`, nen can tu cai cac thu vien Python can thiet nhu Flask, BeautifulSoup, requests, firebase_admin, yt_dlp, Whisper va deep_translator.

## Firestore Collections

Cac collection chinh:

```text
users
vocabulary_sets
vocabulary_words
grammar_topics
grammar_questions
listening_topics
video_lessons
articles
user_progress
saved_articles
saved_videos
saved_vocabulary
```

Mot so du lieu phu nhu subtitle duoc luu trong subcollection, vi du:

```text
video_lessons/{videoId}/subtitles
```

## Luong hoat dong chinh

### Authentication

Ung dung khoi tao Firebase trong `lib/main.dart`, sau do mo man hinh dang nhap.

Sau khi dang nhap thanh cong:

- Neu user co role `admin`, chuyen toi man hinh admin
- Neu user chua chon ngon ngu, chuyen toi man hinh chon ngon ngu
- Neu user da hoan tat thiet lap, chuyen toi man hinh home

### Vocabulary

Luong hoc tu vung:

```text
HomeScreen
-> VocabularyScreen
-> LessonScreen
-> user_progress
```

Tien do hoc duoc luu trong Firestore theo user.

### Grammar

Luong hoc ngu phap:

```text
GrammarScreen
-> GrammarDetailScreen
-> GrammarQuizScreen
-> user_progress
```

### Listening

Luong luyen nghe:

```text
ListeningTopicsScreen
-> ListeningSectionsScreen
-> ListeningDetailScreen
-> user_progress
```

### Video Lessons

Luong hoc qua video:

```text
VideoScreen
-> VideoPlayerScreen
-> video_lessons/{videoId}/subtitles
```

### Admin CMS

Admin co the quan ly noi dung hoc tap truc tiep tu giao dien admin.

## Mot so file quan trong

| File | Chuc nang |
|---|---|
| `lib/main.dart` | Khoi tao Firebase, Provider va route chinh |
| `lib/firebase_options.dart` | Cau hinh Firebase generated |
| `lib/core/theme/app_theme.dart` | Theme nguoi dung va admin |
| `lib/core/providers/user_provider.dart` | Quan ly du lieu user hien tai |
| `lib/data/models/` | Chua model du lieu Firestore |
| `lib/data/repositories/` | Chua logic truy cap du lieu |
| `lib/features/auth/` | Dang nhap, dang ky, social login |
| `lib/features/vocabulary/` | Man hinh hoc tu vung |
| `lib/features/lesson/` | Cac mode hoc tu vung |
| `lib/features/grammar/` | Hoc va quiz ngu phap |
| `lib/features/listening/` | Luyen nghe dictation |
| `lib/features/video/` | Video lesson va phu de |
| `lib/features/news/` | Bai viet/tin tuc |
| `lib/features/admin/` | Giao dien quan tri |
| `backend/extract_articles/app.py` | API crawl va luu bai viet |
| `backend/auto_subtitle_processor.py` | Script tao phu de video tu dong |

## Kiem thu

Chay test Flutter:

```bash
flutter test
```

Hien du an moi co test co ban. Nen bo sung test cho:

- Auth routing
- Mapping model Firestore
- Vocabulary progress
- Grammar quiz scoring
- Saved articles/videos/vocabulary
- Repository/service logic

## Luu y bao mat

- Khong commit Firebase service account key
- Khong hard-code admin password trong source code production
- Nen dung Firebase Security Rules de gioi han quyen doc/ghi
- Nen rotate key neu secret da tung duoc dua len GitHub
- Nen dung bien moi truong hoac secret manager cho backend

## Huong phat trien tiep theo

- Chuan hoa toan bo truy cap Firestore qua repository/service
- Hoan thien cac API con tra du lieu rong trong video repository
- Upload anh vocabulary len Firebase Storage thay vi luu base64
- Loai bo mock data khong con dung
- Them test cho cac luong hoc chinh
- Cai thien bao mat admin va Firebase rules

## Tac gia

Du an Amingo duoc phat trien phuc vu muc tieu hoc tieng Anh thong qua nhieu hinh thuc tuong tac: tu vung, ngu phap, nghe, video va doc hieu.

## License

Them license phu hop cho du an, vi du:

```text
MIT License
```
