# Handover Document - Amingo

## 1. Tong Quan & Cong Nghe Su Dung

Amingo la ung dung hoc tieng Anh bang Flutter, gom giao dien nguoi dung va admin. Cac module chinh: dang nhap/dang ky, chon ngon ngu, vocabulary, grammar, listening dictation, video lessons co phu de, news/articles, saved lessons, profile va admin CMS.

Cong nghe chinh:

| Nhom | Cong nghe |
|---|---|
| Mobile/Web/Desktop | Flutter, Dart SDK `>=3.10.7 <4.0.0` |
| State management | `provider 6.1.5+1` |
| Backend-as-a-Service | Firebase Core `4.8.0`, Firebase Auth `6.2.0`, Cloud Firestore `6.4.0`, Firebase Storage `13.4.0` |
| Auth social | Google Sign-In `7.2.0`, Facebook Auth `7.1.6` |
| Media | `youtube_player_flutter 10.0.1`, `audioplayers 6.6.0`, `image_picker 1.2.2`, `file_picker 11.0.2` |
| UI | Material 3, `google_fonts 6.3.3` |
| Backend Python phu tro | Flask, BeautifulSoup, requests, firebase_admin, yt_dlp, OpenAI Whisper, deep_translator. Chua thay `requirements.txt` nen chua khoa version Python deps. |
| Database chinh | Cloud Firestore |

Collection Firestore chinh: `users`, `vocabulary_sets`, `vocabulary_words`, `grammar_topics`, `grammar_questions`, `listening_topics`, `video_lessons`, `articles`, `user_progress`, `saved_articles`, `saved_videos`, `saved_vocabulary`.

Luu y bao mat: repo hien co file khoa Firebase service account trong `backend/my_key.json` va `backend/extract_articles/firebase_key.json`. Khong nen commit cac file nay.

## 2. Cau Truc Thu Muc

```text
Amingo/
├─ lib/
│  ├─ main.dart
│  ├─ firebase_options.dart
│  ├─ core/
│  │  ├─ constants/
│  │  ├─ providers/
│  │  ├─ theme/
│  │  ├─ utils/
│  │  └─ widgets/
│  ├─ data/
│  │  ├─ models/
│  │  ├─ repositories/
│  │  ├─ services/
│  │  └─ mock/
│  └─ features/
│     ├─ auth/
│     ├─ home/
│     ├─ vocabulary/
│     ├─ lesson/
│     ├─ grammar/
│     ├─ listening/
│     ├─ video/
│     ├─ news/
│     ├─ save/
│     ├─ profile/
│     ├─ language_selection/
│     └─ admin/
├─ backend/
│  ├─ extract_articles/
│  ├─ services/
│  └─ auto_subtitle_processor.py
├─ assets/
│  ├─ logo/
│  └─ audio/
├─ android/ ios/ web/ windows/ macos/ linux/
├─ pubspec.yaml
├─ pubspec.lock
└─ firebase.json
```

`lib/core` chua theme, mau, widget dung chung, provider user. `lib/data` chua model du lieu va lop truy cap Firestore/service nghiep vu. `lib/features` la module UI theo chuc nang. `backend` la script/API Python ho tro trich xuat bai bao va tu sinh phu de video.

## 3. Ban Do Chuc Nang File Quan Trong

| File | Nhiem vu | Class/Ham chinh |
|---|---|---|
| `lib/main.dart` | Khoi tao Firebase, Provider, route dau vao | `main`, `MyApp` |
| `lib/firebase_options.dart` | Cau hinh Firebase generated | `DefaultFirebaseOptions` |
| `lib/core/theme/app_theme.dart` | Theme user/admin | `AppTheme.lightTheme`, `adminTheme` |
| `lib/core/constants/app_colors.dart` | Bang mau app | `AppColors`, `AppGradients` |
| `lib/core/constants/app_constants.dart` | Hang so, admin demo credential | `AppConstants` |
| `lib/core/providers/user_provider.dart` | Load user Firestore sau dang nhap | `UserProvider.fetchUserData`, `clearUser` |
| `lib/core/widgets/smart_image.dart` | Hien thi anh URL/asset/base64 | `SmartImage` |
| `lib/data/models/*.dart` | DTO/model Firestore | `VocabularySet`, `VocabularyWord`, `GrammarTopic`, `VideoLesson`, `NewsArticle`, `ListeningTopic/Section/Lesson`, `DictationLine` |
| `lib/data/repositories/listening_repository.dart` | CRUD/stream listening topics, sections, lessons, dictation, progress | `watchTopics`, `watchSections`, `watchLessons`, `markLessonCompleted` |
| `lib/data/repositories/video_repository.dart` | Stream/search video, subtitle, admin video CRUD | `watchVideoLessons`, `fetchSubtitles`, `createVideoLesson`, `updateSubtitleFull` |
| `lib/data/services/article_service.dart` | Article stream, read status, bookmark | `getArticles`, `markAsRead`, `toggleBookmark`, `getSavedArticles` |
| `lib/data/services/video_service.dart` | Watched/saved video per user | `markAsWatched`, `toggleSaveVideo` |
| `lib/features/auth/screens/login_screen.dart` | Login email/password, kiem tra email verified, route theo role/language | `_handleLogin` |
| `lib/features/auth/screens/register_screen.dart` | Dang ky Firebase Auth, tao document `users` | `_handleSignup` |
| `lib/features/auth/widgets/social_buttons.dart` | Google/Facebook login va tao/cap nhat user Firestore | `SocialButtons` |
| `lib/features/home/screens/home_screen.dart` | Dashboard user, dieu huong module hoc | `HomeScreen` |
| `lib/features/vocabulary/screens/vocabulary_screen.dart` | Danh sach bo tu, search title, progress, vao lesson | `_loadData`, `_navigateToLesson`, `_resetSet` |
| `lib/features/lesson/screens/lesson_screen.dart` | Luong hoc tu vung bang flashcard, luu mastered/completed | `_loadData`, `_handleKnow`, `_markTopicCompleted` |
| `lib/features/lesson/widgets/*` | Cac mode hoc: flashcard, multiple choice, matching, listening, spelling | `Flashcard`, `MultipleChoiceWidget`, `MatchingWidget` |
| `lib/features/grammar/repository/grammar_repository.dart` | CRUD grammar topic/question, luu diem quiz | `getAllTopics`, `saveQuizResult`, `addGrammarTopic` |
| `lib/features/grammar/screens/*` | Danh sach grammar, detail, quiz | `GrammarScreen`, `GrammarDetailScreen`, `GrammarQuizScreen` |
| `lib/features/listening/screens/*` | Topic -> section -> lesson -> dictation detail | `ListeningTopicsScreen`, `ListeningSectionsScreen`, `ListeningDetailScreen` |
| `lib/features/video/screens/video_screen.dart` | Danh sach video published, filter level, featured, watched | `VideoScreen._openVideo` |
| `lib/features/video/screens/video_player_screen.dart` | YouTube player + transcript/subtitle seek | `_loadData`, `_onPlayerStateChange` |
| `lib/features/news/screens/news_screen.dart` | Danh sach article tu Firestore | `NewsScreen` |
| `lib/features/news/screens/news_detail_screen.dart` | Chi tiet bai doc, tra tu/luu vocabulary | `ArticleDetailScreen` |
| `lib/features/save/screens/saved_lessons_screen.dart` | Tab saved articles/videos/vocabulary | `SavedLessonsScreen` |
| `lib/features/profile/screens/profile_screen.dart` | Ho so user, settings Firestore | `ProfileScreen` |
| `lib/features/admin/screens/admin_dashboard_screen.dart` | Shell admin, side menu, thong ke Firestore | `AdminDashboardScreen`, `_DashboardMetrics` |
| `lib/features/admin/screens/admin_vocabulary_*` | CRUD vocabulary set/word, anh tu vung | `AdminVocabularyScreen`, `AdminVocabularyWordForm` |
| `lib/features/admin/screens/admin_grammar_*` | CRUD grammar topic/question | `AdminGrammarScreen`, `AdminGrammarForm` |
| `lib/features/admin/screens/admin_listening_*` | CRUD listening topic/section/lesson/dictation lines | `AdminListeningScreen`, `AdminListeningSectionsScreen` |
| `lib/features/admin/screens/admin_video_*` | CRUD video, publish, subtitle management | `AdminVideoScreen`, `AdminVideoDetailScreen` |
| `lib/features/admin/screens/admin_news_screen.dart` | CRUD article/news | `AdminNewsScreen` |
| `backend/extract_articles/app.py` | Flask API `/extract-article`, crawl URL, luu article vao Firestore | `extract_article` |
| `backend/extract_articles/preprocessing.py` | Clean text, loc paragraph, detect category/difficulty | `clean_text`, `detect_category` |
| `backend/auto_subtitle_processor.py` | Quet video chua co subtitle, tai audio, Whisper, dich VI, luu subcollection | `start_auto_sub` |
| `backend/services/youtube_service.py` | Tai audio YouTube bang yt_dlp | `download_audio` |
| `backend/services/whisper_service.py` | Transcribe audio thanh subtitle segments | `generate_subtitles` |

## 4. Luong Hoat Dong Chinh

Khoi chay app: `main.dart` goi `Firebase.initializeApp` bang `firebase_options.dart`, tao `UserProvider`, mo `MaterialApp` voi route `/` la `LoginScreen`.

Luong user: `LoginScreen._handleLogin` dang nhap Firebase Auth, reload user, kiem tra `emailVerified`, doc `users/{uid}`. Neu `role == admin` chuyen `AdminDashboardScreen`; neu user chua chon language chuyen `LanguageSelectionScreen`; con lai vao `HomeScreen`.

Luong hoc vocabulary: `HomeScreen` -> `VocabularyScreen` -> doc `vocabulary_sets`, `vocabulary_words`, `user_progress/{uid}` -> mo `LessonScreen` voi danh sach `VocabularyWord` -> `LessonScreen` luu mastered vao `user_progress/{uid}/vocabulary` va completed topic vao `user_progress/{uid}/completed_topics`.

Luong grammar: `GrammarScreen`/`GrammarRepository` doc `grammar_topics`, `grammar_questions` -> `GrammarQuizScreen` cham diem -> luu `user_progress/{uid}/grammar`, co the ghi completed topic.

Luong listening: `ListeningTopicsScreen` stream `listening_topics` -> sections -> lessons -> `ListeningDetailScreen` doc `dictation_lines` -> khi hoan tat goi `ListeningRepository.markLessonCompleted`, luu `user_progress/{uid}/listening`.

Luong video: `VideoScreen` stream `video_lessons` voi `isPublished` -> `VideoPlayerScreen` dung YouTube player -> `VideoRepository.fetchSubtitles` doc `video_lessons/{videoId}/subtitles` -> `VideoService` luu watched/saved.

Luong admin: `AdminDashboardScreen` chua menu trai va cac man CRUD. Hau het man admin ghi truc tiep Firestore, mot phan di qua repository. Admin login co 2 duong: user login theo role Firestore, va `/admin` dung credential hard-coded trong `AppConstants`.

Backend phu tro: Flask `/extract-article` nhan URL, crawl HTML, phan tich text, luu `articles`. Script `auto_subtitle_processor.py` quet `video_lessons.hasSubtitles == false`, tai audio YouTube, chay Whisper, dich subtitle sang tieng Viet, luu vao subcollection `subtitles`.

## 5. Hien Trang & Next Steps

Da tuong doi hoan thien: auth email/password + social, home navigation, CRUD admin cho vocabulary/grammar/listening/video/news, user flow vocabulary/grammar/listening/video/news, saved items, dashboard thong ke Firestore, backend crawl article va auto subtitle.

Con dang do/rui ro:

- `VideoRepository.fetchVideoLessons()` tra `[]`, `watchFeaturedVideos()` tra `Stream.empty`.
- Mock cu van con trong `lib/data/mock`.
- Admin credential hard-coded.
- Anh vocabulary admin luu base64 vao `imageUrl` nhung mot so user widget chua dung `SmartImage`.
- Firebase service account dang nam trong repo.
- Nhieu man truy cap Firestore truc tiep thay vi qua repository.
- Chua thay test dang ke ngoai `widget_test.dart`.

De xuat 5 viec tiep theo:

1. Chuan hoa data access: dua Firestore logic cua man hinh ve repository/service, tranh duplicate query va schema lech.
2. Sua chien luoc anh vocabulary: upload Firebase Storage, luu URL; hoac dung `SmartImage` dong nhat o moi widget.
3. Don bao mat: xoa service account khoi repo, rotate key, dung `.gitignore`/secret manager; bo admin password hard-coded.
4. Hoan thien cac API dang do trong repository, xoa mock/boilerplate khong dung, chuan hoa ten collection/field.
5. Them test toi thieu cho auth routing, repository mapping, vocabulary lesson progress, grammar quiz scoring va saved items.
