# Amingo

Amingo is an English learning application built with Flutter. It helps learners practice vocabulary, grammar, listening dictation, video lessons with subtitles, English articles/news, and saved learning content. The project also includes an admin interface for managing learning materials.

## Main Features

### User

- Sign up and sign in with email/password
- Social login with Google and Facebook
- Select a learning language
- Learn vocabulary by topic/set
- Practice with flashcards, multiple choice, matching, listening, and spelling exercises
- Learn grammar by topic
- Take grammar quizzes and save progress
- Practice listening dictation
- Watch YouTube-based video lessons with subtitles
- Read English articles/news
- Save favorite articles, videos, and vocabulary
- Manage user profile

### Admin

- Firestore data statistics dashboard
- Manage vocabulary sets and words
- Manage grammar topics and quiz questions
- Manage listening topics, sections, and lessons
- Manage video lessons and subtitles
- Manage articles/news

## Tech Stack

| Category | Technology |
|---|---|
| Frontend | Flutter, Dart |
| State Management | Provider |
| Backend-as-a-Service | Firebase Auth, Cloud Firestore, Firebase Storage |
| Social Auth | Google Sign-In, Facebook Auth |
| Media | YouTube Player, Audio Players, Image Picker, File Picker |
| UI | Material 3, Google Fonts |
| Supporting Backend | Python, Flask, BeautifulSoup, requests, firebase_admin, yt_dlp, OpenAI Whisper, deep_translator |
| Database | Cloud Firestore |

## Project Structure

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

## Requirements

Before running the project, install:

- Flutter SDK
- Dart SDK `>=3.10.7 <4.0.0`
- Firebase CLI
- Android Studio or VS Code
- Python 3 if you want to run the supporting backend scripts
- A physical device or emulator

Check your Flutter environment:

```bash
flutter doctor
```

## Installation

Clone the repository:

```bash
git clone https://github.com/Tienndat2306/Amingo.git
cd Amingo
```

Install Flutter dependencies:

```bash
flutter pub get
```

## Firebase Setup

This project uses Firebase for authentication, database, and storage.

Enable and configure the following services in Firebase Console:

- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Google Sign-In
- Facebook Login, if Facebook authentication is used

After configuring Firebase, regenerate the Firebase configuration file:

```bash
flutterfire configure
```

This command creates or updates:

```text
lib/firebase_options.dart
```

## Secret Configuration

Do not commit secret files or Firebase service account keys to GitHub.

The following files should be excluded from Git:

```text
backend/my_key.json
backend/extract_articles/firebase_key.json
```

Add them to `.gitignore`:

```gitignore
backend/my_key.json
backend/extract_articles/firebase_key.json
*.env
```

If these keys were already committed, rotate them in Firebase Console.

## Run the App

Run on the default device:

```bash
flutter run
```

Run on Chrome:

```bash
flutter run -d chrome
```

Run on Android:

```bash
flutter run -d android
```

## Build

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

## Supporting Backend

The `backend/` directory contains Python scripts/APIs for content processing.

### Extract Article API

Main file:

```text
backend/extract_articles/app.py
```

Responsibilities:

- Receive an article URL
- Crawl HTML content
- Clean extracted text
- Detect category and difficulty
- Save the article to Firestore

Run the API:

```bash
cd backend/extract_articles
python app.py
```

### Auto Subtitle Processor

Main file:

```text
backend/auto_subtitle_processor.py
```

Responsibilities:

- Scan videos without subtitles
- Download audio from YouTube using `yt_dlp`
- Generate subtitles with Whisper
- Translate subtitles into Vietnamese
- Save subtitles to Firestore

Run the script:

```bash
cd backend
python auto_subtitle_processor.py
```

Note: the project currently does not include a `requirements.txt` file, so Python dependencies such as Flask, BeautifulSoup, requests, firebase_admin, yt_dlp, Whisper, and deep_translator must be installed manually.

## Firestore Collections

Main collections:

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

Some nested data, such as subtitles, is stored in subcollections. Example:

```text
video_lessons/{videoId}/subtitles
```

## Main Application Flows

### Authentication

The app initializes Firebase in `lib/main.dart`, then opens the login screen.

After successful login:

- If the user has the `admin` role, the app opens the admin dashboard
- If the user has not selected a language, the app opens the language selection screen
- If setup is complete, the app opens the home screen

### Vocabulary

Vocabulary learning flow:

```text
HomeScreen
-> VocabularyScreen
-> LessonScreen
-> user_progress
```

Learning progress is stored in Firestore per user.

### Grammar

Grammar learning flow:

```text
GrammarScreen
-> GrammarDetailScreen
-> GrammarQuizScreen
-> user_progress
```

### Listening

Listening practice flow:

```text
ListeningTopicsScreen
-> ListeningSectionsScreen
-> ListeningDetailScreen
-> user_progress
```

### Video Lessons

Video lesson flow:

```text
VideoScreen
-> VideoPlayerScreen
-> video_lessons/{videoId}/subtitles
```

### Admin CMS

Admins can manage learning content directly from the admin interface.

## Important Files

| File | Purpose |
|---|---|
| `lib/main.dart` | Initializes Firebase, Provider, and the main route |
| `lib/firebase_options.dart` | Generated Firebase configuration |
| `lib/core/theme/app_theme.dart` | User and admin themes |
| `lib/core/providers/user_provider.dart` | Manages current user data |
| `lib/data/models/` | Firestore data models |
| `lib/data/repositories/` | Data access logic |
| `lib/features/auth/` | Login, registration, and social login |
| `lib/features/vocabulary/` | Vocabulary learning screens |
| `lib/features/lesson/` | Vocabulary practice modes |
| `lib/features/grammar/` | Grammar lessons and quizzes |
| `lib/features/listening/` | Listening dictation |
| `lib/features/video/` | Video lessons and subtitles |
| `lib/features/news/` | Articles/news |
| `lib/features/admin/` | Admin interface |
| `backend/extract_articles/app.py` | API for crawling and saving articles |
| `backend/auto_subtitle_processor.py` | Script for automatically generating video subtitles |

## Testing

Run Flutter tests:

```bash
flutter test
```

The project currently has only basic tests. Recommended test coverage includes:

- Auth routing
- Firestore model mapping
- Vocabulary progress
- Grammar quiz scoring
- Saved articles/videos/vocabulary
- Repository/service logic

## Security Notes

- Do not commit Firebase service account keys
- Do not hard-code admin passwords in production source code
- Use Firebase Security Rules to restrict read/write access
- Rotate secrets if they were ever pushed to GitHub
- Use environment variables or a secret manager for backend credentials

## Roadmap

- Standardize Firestore access through repositories/services
- Complete unfinished video repository APIs that currently return empty data
- Upload vocabulary images to Firebase Storage instead of storing base64 data
- Remove unused mock data
- Add tests for the main learning flows
- Improve admin authentication and Firebase security rules

## Author

Amingo is developed as an English learning project that combines vocabulary, grammar, listening, video-based learning, and reading practice.

## License

Add the appropriate license for this project, for example:

```text
MIT License
```
