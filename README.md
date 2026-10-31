# 🏗️ Hazari App – Labour Management System

A full-stack Labour Management and Attendance System developed using **Java, Spring Boot, Flutter, and MySQL**. The application helps contractors manage labourers, track daily attendance, handle leave requests, and manage labour-related information.

## 📌 Project Overview

Hazari App is designed to simplify labour management by providing separate dashboards for contractors and labourers. It connects a Flutter frontend with a Spring Boot REST API and a MySQL database.

The system aims to improve attendance management, communication, and transparency between contractors and labourers.

## ✨ Features

### 👷 Labour Features
- User registration and login.
- Labour dashboard.
- Daily attendance check-in and check-out.
- Attendance history.
- Camera-based attendance photo capture.
- GPS location capture during attendance.
- Leave request submission.
- Leave request history.

### 🏢 Contractor Features
- Contractor registration and login.
- Contractor dashboard.
- Add and manage labourers.
- View labour details.
- Monitor daily attendance.
- View pending leave requests.
- Approve or reject leave requests.
- View payment summary.

### 🔐 Authentication and Security
- Spring Security integration.
- JWT-based authentication implementation.
- Password encryption using BCrypt.
- Role-based user identification.

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| Java 17 | Backend programming |
| Spring Boot 3.2.1 | REST API development |
| Spring Security | Authentication and security |
| JWT | Token-based authentication |
| Hibernate / JPA | Database operations |
| MySQL | Database |
| Flutter | Frontend development |
| Dart | Flutter programming language |
| Camera Plugin | Attendance photo capture |
| Geolocator | GPS location |
| Maven | Backend dependency management |

## 🏛️ System Architecture

```text
             Flutter Application
                     |
          ------------------------
          |                      |
    Labour Dashboard      Contractor Dashboard
          |                      |
          ------------------------
                     |
                  ApiService
                     |
                REST APIs
                     |
             Spring Boot Backend
                     |
          ------------------------
          |          |           |
      Controller   Service   Security
          |          |           |
          ------------------------
                     |
              Spring Data JPA
                     |
                  MySQL
```

## 📂 Project Structure

```text
Hazari-App/
│
├── backend/
│   ├── src/
│   │   └── main/
│   │       ├── java/com/hazari/
│   │       │   ├── config/
│   │       │   ├── controller/
│   │       │   ├── dto/
│   │       │   ├── entity/
│   │       │   ├── repository/
│   │       │   └── service/
│   │       │
│   │       └── resources/
│   │           └── application.yml
│   │
│   └── pom.xml
│
├── frontend/
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── widgets/
│   │   └── main.dart
│   │
│   └── pubspec.yaml
│
├── docs/
│   └── PROJECT_DOCUMENTATION.docx
│
└── README.md
```

## 🗄️ Database Entities

The project contains the following main entities:

| Entity | Description |
|---|---|
| User | Stores login credentials and user roles |
| Contractor | Stores contractor information |
| Labour | Stores labourer information |
| Attendance | Stores daily attendance records |
| Leave | Stores leave requests and their status |
| Payment | Stores payment-related records |

## 🔄 Main Application Workflows

### 1. User Authentication
- Users log in using their credentials.
- Backend validates the credentials.
- JWT token is generated after successful authentication.
- User role determines the dashboard.

### 2. Attendance Management
- Labourer opens the attendance screen.
- Captures an attendance photo.
- Retrieves GPS coordinates.
- Checks in and checks out.
- Attendance information is stored in MySQL.

### 3. Leave Management
- Labourer submits a leave request.
- Contractor views pending requests.
- Contractor approves or rejects the request.
- Leave status is updated.

### 4. Labour Management
- Contractor adds labourers.
- Labour records are associated with contractors.
- Contractor can view associated labour information.

## ⚙️ Installation and Setup

### Prerequisites

Install the following tools:

- JDK 17
- MySQL Server
- MySQL Workbench
- Maven
- Flutter SDK
- Android Studio or Visual Studio Code

### Step 1: Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/Hazari-App.git
cd Hazari-App
```

### Step 2: Configure MySQL

Create the database:

```sql
CREATE DATABASE hazari_db;
```

Update your backend `application.yml` with your local database credentials.

### Step 3: Run Spring Boot Backend

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

Backend runs on:

```text
http://localhost:8080
```

### Step 4: Run Flutter Frontend

Open another terminal:

```bash
cd frontend
flutter pub get
flutter run
```

To run on Chrome:

```bash
flutter run -d chrome
```

**Note:** Update the Flutter API base URL according to your device or emulator network configuration.

## 🔗 API Modules

The backend provides REST API modules for:

- Authentication – `/api/auth`
- Labour Management – `/api/labour`
- Contractor Management – `/api/contractor`
- Image Upload – `/api/upload`

Refer to the source code for individual endpoint methods and request parameters.

## 🚀 Future Enhancements

- Real-time labour location tracking.
- Map integration for attendance locations.
- Push notifications.
- Automated wage calculation.
- Monthly attendance reports.
- Advanced analytics dashboard.
- Improved role-based authorization.
- Secure image storage.

## 📚 Project Documentation

For detailed technical information, refer to:

The documentation includes:

- System architecture.
- Backend and frontend implementation.
- Database design.
- REST API details.
- Application workflows.
- Installation and configuration.
- Testing and code review findings.

## 💡 Recommendations

The application can be improved by introducing real-time location tracking, automated attendance verification, advanced reporting, secure image management, and improved authentication controls.

These enhancements can make labour management more efficient, transparent, and reliable.

## 👨‍💻 Author

**Indrajeet Yadav**

Full Stack Developer | Java | Spring Boot | Flutter | MySQL

## ⭐ Support

If you find this project useful, consider giving it a ⭐ on GitHub.

---

**Note:** This project is under development. Some features and security improvements may require further implementation before production deployment.
