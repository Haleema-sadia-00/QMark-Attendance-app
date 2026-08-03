# Smart Attendance App

A professional, student-level attendance management app built with **Flutter** and **Firebase**. The app supports three user roles: **Student, Teacher, and Admin**. Attendance is managed via QR codes, and all data is stored and updated in real-time using Firebase.

## Features
- **Authentication:** Secure login/signup for students, teachers, and admin.
- **Role-based Panels:** Separate dashboards for each user type.
- **Student Management:** Add, update, delete, and view students (admin/teacher).
- **Class Management:** Teachers can create and manage classes.
- **Attendance via QR Code:** Teachers generate QR codes; students scan to mark attendance.
- **Real-time Updates:** All lists and attendance records update instantly.
- **Roll Number Assignment:** Students are assigned roll numbers alphabetically.
- **Responsive UI:** Works on both mobile and web.
- **User-friendly Error Messages:** All forms and actions provide clear feedback.
- **Permissions:** Camera and internet permissions handled for QR scanning.

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase Project](https://firebase.google.com/)
- Android Studio/VS Code or any Flutter-supported IDE

### Setup
1. **Clone the repository:**
   ```bash
   git clone <repo-url>
   cd semproject
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Firebase Setup:**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective folders.
   - Update `lib/firebase_options.dart` if needed.
4. **Run the app:**
   ```bash
   flutter run
   ```

## Usage
- **Login/Signup:** Register as student, teacher, or admin. Await admin approval if required.
- **Admin Panel:** Manage users, approve accounts, and oversee all data.
- **Teacher Panel:** Create classes, add students, generate QR codes for attendance.
- **Student Panel:** Join classes, scan QR codes to mark attendance, view attendance history.

## Credits
**Developed by:**
- Halima Sadia (22-ARID-5141)

---
Screen Shots
<img width="291" height="582" alt="image" src="https://github.com/user-attachments/assets/4db11e93-3f2f-4137-bcfd-386b2a121986" />
<img width="301" height="590" alt="image" src="https://github.com/user-attachments/assets/2434d430-dde7-4734-8319-8a2c12c58753" />
<img width="288" height="510" alt="image" src="https://github.com/user-attachments/assets/bb7c166c-3435-4590-9a8a-2342150d736a" />
<img width="275" height="595" alt="image" src="https://github.com/user-attachments/assets/212a0dab-3299-4ae3-9166-f48ddfaaaa43" />
<img width="215" height="428" alt="image" src="https://github.com/user-attachments/assets/d6bb4b59-ef5c-4914-8adc-7f42b9a7eb71" />
<img width="277" height="600" alt="image" src="https://github.com/user-attachments/assets/d82498e3-2114-4dd2-81c3-46014f5f598e" />
<img width="288" height="510" alt="image" src="https://github.com/user-attachments/assets/8a005f1a-78aa-4046-ab99-c47158ae5dc3" />

