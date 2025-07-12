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
- Mariyam Norren (22-ARID-5145)

---
*This project is submitted as a student-level assignment. All code is clean, well-commented, and follows best practices for Flutter and Firebase apps.*
