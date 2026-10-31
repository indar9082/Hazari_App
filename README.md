HAZARI APP

Technical Project Documentation

Labour Management, Attendance and Contractor Operations

Prepared from the supplied README and hazari-app source archive
Author listed in project README: Indrajeet Yadav
Documentation date: 31 October 2026


Hazari App • Source-code review • 31 October 2026

HAZARI APP  |  TECHNICAL PROJECT DOCUMENTATION

Document Scope and Source Basis

This document describes the Hazari application represented by the uploaded README and hazari-app.zip archive. The archive contains a Java Spring Boot backend and a Flutter frontend. The descriptions below are grounded in the supplied source files.

Important: the README is brief. The detailed feature descriptions, class inventory and API list were derived from the source code in the archive. Where the archive does not demonstrate a complete implementation, the limitation is explicitly identified. This document does not claim that the application has been deployed or production-tested.

Source reviewed

What it establishes

README.md

Project name, high-level features, listed technology stack and author.

backend/pom.xml and application.yml

Backend framework/dependency versions, Java version, server port, MySQL configuration, JWT and upload settings.

Backend Java source

Controllers, DTOs, entities, repositories, services, security and business logic.

frontend/pubspec.yaml and lib/

Flutter dependencies, routes, screens, models, API calls, camera and location services.

1. Project Overview

Hazari is a full-stack labour-management application intended to connect contractors and labourers through a Flutter user interface and a Spring Boot REST API. The project README lists user management, attendance management, backend REST APIs and mobile application integration.

The codebase contains separate user roles for CONTRACTOR and LABOUR. Contractor-facing functions include contractor profile/dashboard data, labour listing, today’s attendance, leave approvals/rejections and a payment summary. Labour-facing functions include profile/dashboard data, attendance check-in/check-out, leave requests and viewing leave records.

1.1 Objectives

Maintain user accounts and distinguish contractor and labour roles.

Allow contractors to add and view labour records associated with them.

Record labour attendance with timestamps, optional photo paths and GPS coordinates.

Allow labourers to submit leave requests and contractors to approve or reject them.

Expose backend REST endpoints for the Flutter application.

Provide payment-related data structures and a contractor payment-summary endpoint.

2. Technology Stack

Layer

Technology found in source

Purpose

Frontend

Flutter / Dart (SDK constraint >=3.9.0 <4.0.0)

Cross-platform user interface.

HTTP integration

http package ^1.1.0

Calls backend REST endpoints.

Backend

Java 17, Spring Boot 3.2.1

REST API and application logic.

Persistence

Spring Data JPA, Hibernate

Maps Java entities to relational tables.

Database

MySQL Connector/J

Connects backend to MySQL.

Authentication

Spring Security, JJWT 0.11.5, BCrypt

Authentication primitives and JWT creation/filtering.

Camera

camera ^0.10.5+5; camera_web ^0.3.2+2

Captures attendance photos.

Location

geolocator ^14.0.2; permission_handler ^12.0.1

Reads device location and permissions.

Utilities

intl, path_provider

Date/time formatting and temporary file paths.

Build

Maven, Spring Boot Maven plugin

Builds and runs backend.

The project README also lists Java, Spring Boot, MySQL and Flutter. The more specific versions above are taken from pom.xml and pubspec.yaml.

3. System Architecture

The application follows a client-server structure. Flutter screens call ApiService methods. ApiService sends HTTP requests to the Spring Boot controllers. Controllers call service classes and repositories. Spring Data JPA repositories read and write entity data in MySQL.

Flutter UI (screens/widgets)
        |
        v
ApiService (HTTP + JSON + JWT header)
        |
        v
Spring Boot REST Controllers
        |
        v
Service Layer (business operations)
        |
        v
Spring Data JPA Repositories
        |
        v
MySQL database

3.1 Main request flow

A user opens the Flutter application and starts at the /login route.

The login screen submits username and password through ApiService.

AuthController delegates authentication to AuthService.

AuthService authenticates the user, creates a JWT and returns token, role and userId. For LABOUR users it also attempts to resolve labourId.

Flutter stores the returned token in ApiService memory and uses it as a Bearer token on selected subsequent requests.

For attendance, the Flutter client gathers a photo path and location values and submits them to the labour attendance endpoints.

The backend stores attendance and other domain records using repositories.

4. Repository Structure

hazari-app/
├── backend/
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/hazari/
│       │   ├── config/       # security, JWT and image storage configuration
│       │   ├── controller/   # REST endpoints
│       │   ├── dto/          # request/response data objects
│       │   ├── entity/       # persistent domain entities
│       │   ├── repository/   # database access interfaces
│       │   └── service/      # application/business logic
│       └── resources/application.yml
└── frontend/
    ├── pubspec.yaml
    └── lib/
        ├── main.dart
        ├── models/           # attendance, leave, payment and user models
        ├── screens/          # login, dashboards and feature screens
        ├── services/         # API, camera and location services
        └── widgets/          # reusable UI components

The archive also contains generated folders such as backend/target, frontend/build, frontend/.dart_tool and IDE metadata. These are build/development artifacts rather than core application source and should generally not be committed as application source.

5. Backend Design

5.1 Application entry point

HazariApplication.java is the Spring Boot application entry point. The backend Maven project uses groupId com.hazari, artifactId backend, version 0.0.1-SNAPSHOT and Java 17.

5.2 Controllers

Controller

Base path

Responsibilities evidenced in source

AuthController

/api/auth

Login, registration and forgot-password request handling.

LabourController

/api/labour

Add/list/profile labour, check-in/out, labour dashboard/today status, leave requests and labour leave history.

ContractorController

/api/contractor

Contractor profile/dashboard, pending leave list, leave approval/rejection, payment summary and today attendance.

ImageUploadController

/api/upload

Accepts an image multipart upload and writes it to configured upload directory.

5.3 Services

Service

Role

AuthService

Authenticates users, registers user accounts, generates JWT response data and processes password reset requests.

AttendanceService

Creates/updates same-day attendance records and prepares today-attendance summaries.

ContractorService

Provides contractor-related service operations used by the controller.

LeaveService

Creates/updates leave status operations used by labour and contractor flows.

PaymentService

Contains payment-related service operations and is used for contractor payment summary.

UserDetailsServiceImpl

Loads user details for Spring Security.

LocationService

A backend class exists but is empty in the supplied archive.

5.4 Security configuration

The backend defines BCryptPasswordEncoder, an AuthenticationManager, stateless session management, CORS configuration and a JWT authentication filter/JWT utility. The current SecurityConfig has a broad request matcher /**.permitAll() before its more specific route matchers. Because the first matching authorization rule is permissive, this configuration effectively makes all routes public at the authorization layer. JWT-related classes exist, but this configuration must be reviewed before treating protected endpoints as secured.

CORS is configured with wildcard origin patterns, methods and headers, with credentials enabled. This is permissive and should be narrowed for production.

5.5 DTOs

The DTO package contains AttendanceDto, AttendanceInDto, AttendanceOutDto, ChangePasswordRequest, ContractorProfileDto, ForgotPasswordRequest, LeaveRequestDto, LoginRequest, LoginResponse, PaymentSummaryDto, RegisterRequest, TodayAttendanceDto and UserDto. DTOs define API payload shapes separately from database entities.

6. Database Model

The entity package defines six JPA entities. The exact database schema is created/updated through Hibernate configuration; the supplied archive does not include a SQL schema dump.

Entity

Fields visible in source

Purpose

User

id, username, password, role, phone

Login identity and role (LABOUR or CONTRACTOR).

Contractor

id, name, phone, companyName, gstNumber, address, totalBudget, projectId, isActive, contractStartDate

Contractor/company profile and project/budget details.

Labour

id, name, phone, aadhaarNumber, dailyRate, contractorId, userId, isActive, hireDate, daysWorked

Labour profile and contractor/user linkage.

Attendance

id, labourId, date, timeIn, timeOut, inPhotoPath, outPhotoPath, inLatitude, inLongitude, outLatitude, outLongitude, status

Daily attendance with time, photo-path and location data.

Leave

id, labourId, contractorId, startDate, endDate, reason, status

Leave request and approval state.

Payment

id, userId, paymentDate, amount, status (default PAID)

Payment record.

6.1 Important relationships

Labour.userId links a labour profile to a User account.

Labour.contractorId associates a labour record with a contractor.

Attendance.labourId identifies the labourer whose attendance is recorded.

Leave stores both labourId and contractorId to associate a request with the relevant parties.

Payment stores userId; the supplied source does not establish a full payment-to-attendance calculation relationship.

The source uses ID fields for several associations. The documentation therefore describes the logical links without asserting that every link is implemented as a JPA object relationship.

7. REST API Reference

The following endpoints are visible in controller annotations and the Flutter ApiService. Request/response details should be confirmed against DTOs and controller implementations when building an external client.

Method

Endpoint

Purpose / notes

POST

/api/auth/login

Authenticate using LoginRequest; response includes token, role and userId. LABOUR response also attempts to include labourId.

POST

/api/auth/register

Create a user account; returns 201 on success in controller.

POST

/api/auth/forgot-password

Password reset using username, phone and newPassword.

POST

/api/labour/add

Create/add a labour record.

GET

/api/labour/profile/{labourId}

Fetch labour profile.

POST

/api/labour/checkin

Submit labourId and check-in photo/location fields.

POST

/api/labour/checkout/{labourId}

Submit check-out photo/location fields for a labourer.

POST

/api/labour/leaves

Create a leave request.

GET

/api/labour/{labourId}/leaves

Fetch leave records for a labourer.

GET

/api/labour/dashboard/{labourId}

Fetch labour dashboard summary.

GET

/api/labour/today-status/{labourId}

Fetch current-day attendance status.

GET

/api/labour/by-contractor/{contractorId}

List labourers associated with a contractor.

GET

/api/contractor/profile/{userId}

Fetch contractor profile.

GET

/api/contractor/leaves/pending?contractorId={id}

Fetch pending leave requests; contractorId is optional in controller.

PUT

/api/contractor/leaves/{leaveId}/approve

Approve a leave request.

PUT

/api/contractor/leaves/{leaveId}/reject

Reject a leave request; controller accepts optional reason.

GET

/api/contractor/payment-summary/{userId}

Fetch contractor payment summary.

GET

/api/contractor/dashboard/{contractorId}

Fetch contractor dashboard summary.

GET

/api/contractor/{contractorId}/today-attendance

Fetch today's attendance for a contractor's labourers.

GET

/api/contractor/attendance/today

Fetch today's attendance through a separate controller route.

POST

/api/upload/image

Multipart image upload using form field named image.

7.1 Frontend/backend route mismatch to check

ApiService.getUserProfile() calls GET /api/user/{userId}, but the supplied backend controller set contains no UserController or matching /api/user/{id} mapping. This call is likely to fail unless the endpoint is supplied by code outside this archive or the client is updated.

ApiService uses a base URL of http://localhost:8080/api. This works only when the client can reach the backend at its own localhost. For an Android emulator, the usual host bridge is 10.0.2.2; for a physical phone, use the development machine's reachable LAN IP; for Flutter Web, localhost refers to the computer running the browser.

8. Flutter Frontend

8.1 Application routes

Route

Screen

/login

LoginScreen

/register

RegisterScreen

/labour_dashboard

LabourDashboard

/contractor_dashboard

ContractorDashboard

/attendance_history

AttendanceHistory

/request_leave

LeaveRequestScreen

/payment_screen

PaymentScreen

/add_labour

AddLabourScreen

/forgot_password

ForgotPasswordScreen

8.2 Screens and reusable widgets

The screens directory includes login, registration, forgot password, contractor dashboard, labour dashboard, add labour, attendance history, leave request and payment screens. Reusable widgets include attendance_tile.dart, leave_card.dart, payment_card.dart and a labour card widget whose filename begins with a leading space in the archive.

8.3 Models and services

Frontend models include Attendance, Leave, Payment and User. ApiService centralizes HTTP calls, JSON decoding and an in-memory token. CameraService initializes the first available camera, captures a picture and saves it under the platform temporary directory. LocationService requests/checks location permission and returns latitude/longitude as a comma-separated string.

9. Core Workflows

9.1 Login and registration

The user enters username and password in the login screen.

Flutter posts JSON to /api/auth/login.

AuthService delegates credential checking to Spring Security's AuthenticationManager.

On successful login, a JWT is generated and token, role and userId are returned.

For a LABOUR role, AuthService searches the Labour table by userId, then by phone. If none is found, the current code creates a Labour record automatically and returns its ID.

Flutter stores the token in ApiService's static in-memory variable.

Registration accepts username, password, phone and role. Passwords are encoded with BCrypt before persistence. The source does not show a complete contractor/labour profile creation flow tied to every registration path; verify the account-to-profile lifecycle.

9.2 Attendance check-in

The labour dashboard uses CameraService and LocationService to obtain a photo and location.

The Flutter client sends an AttendanceInDto to POST /api/labour/checkin.

AttendanceService looks for a record for the labourId and current date, or creates one.

It sets date, timeIn, inPhotoPath, inLatitude and inLongitude, then saves the record.

9.3 Attendance check-out

The Flutter client sends an AttendanceOutDto to POST /api/labour/checkout/{labourId}.

The service finds the current day's attendance record; if none exists it throws an error.

It sets timeOut, outPhotoPath, outLatitude and outLongitude, then saves the record.

Important source finding: the supplied AttendanceService does not calculate worked duration, half-day/full-day/overtime status, or automatically update attendance status during check-out. Those behaviours should not be documented as currently implemented in this archive.

9.4 Leave request and decision

A labourer submits a leave record through POST /api/labour/leaves. The labour leave history is available through GET /api/labour/{labourId}/leaves. The contractor can retrieve pending requests and change the leave status to APPROVED or REJECTED through PUT endpoints.

9.5 Image upload

ImageUploadController accepts a multipart file under the request parameter image, creates the configured upload directory if necessary, stores the file with a UUID-prefixed filename and returns a relative path under /uploads/. The attendance flow in AttendanceService stores photoPath values supplied by the client. Confirm whether the Flutter app uploads the image first and passes the returned path; CameraService itself only saves to a local temporary path.

9.6 Payments

Payment entity, PaymentRepository, PaymentService, PaymentSummaryDto and a contractor payment-summary endpoint exist. The archive does not show a dedicated payment creation endpoint or a complete wage-calculation workflow. The presence of a payment screen does not by itself prove that payment processing is complete.

10. Setup and Run Instructions

10.1 Prerequisites

JDK 17

Maven (or an IDE with Maven support)

MySQL Server and MySQL Workbench (optional)

Flutter SDK compatible with Dart 3.9 or later

Android Studio / Android SDK for Android builds, or Chrome for Flutter Web

A running MySQL instance and a database named hazari_db

10.2 Database configuration

The supplied backend application.yml configures MySQL at localhost:3306, database hazari_db, username root and password root. Update these values to match the local environment. The file currently uses spring.jpa.hibernate.ddl-auto: update, which allows Hibernate to update schema objects automatically during development.

CREATE DATABASE hazari_db;

Do not use the sample root password in a deployed environment. Prefer a dedicated database user with a strong password and limited privileges.

10.3 Run backend

From the backend directory:

cd hazari-app/backend
mvn clean install
mvn spring-boot:run

The configured server port is 8080. The API base path used by the Flutter client is /api.

10.4 Run Flutter frontend

From the frontend directory:

cd hazari-app/frontend
flutter pub get
flutter run

For Chrome:

flutter run -d chrome

Before running on a device, update ApiService.baseUrl to the correct reachable backend address. Ensure platform camera/location permissions are configured for the target platform.

11. Configuration Reference

Setting

Current archive value

Notes

Backend port

8080

server.port in application.yml.

Database

hazari_db

MySQL database in datasource URL.

Database user

root

Development configuration; replace for deployment.

Database password

root

Plain-text sample secret; move to environment variables.

Hibernate DDL

update

Convenient for development; prefer controlled migrations/validate in production.

JWT expiry

86400000 ms

One day.

JWT secret

Placeholder string

Must be replaced with a strong secret and kept outside source control.

Upload directory

./uploads

Relative filesystem path.

Max upload size

10 MB

Both file and request limit in application.yml.

Flutter API URL

http://localhost:8080/api

Must be changed for emulator/physical device as appropriate.

12. Testing and Verification

The archive includes frontend/test/widget_test.dart and the Spring Boot test dependency, but the supplied archive does not establish a comprehensive automated test suite. The following manual checks are recommended.

Area

Suggested test

Database connection

Start backend and confirm it connects to hazari_db without datasource errors.

Registration

Register contractor and labour roles; verify BCrypt-encoded passwords and returned IDs.

Login

Test valid/invalid credentials and verify token, role, userId and labourId response fields.

Labour linkage

Verify Labour.userId and contractorId refer to the intended records.

Check-in

Submit attendance once and confirm date/time/photo path/coordinates are stored.

Duplicate check-in

Submit a second check-in for the same labour/date and verify expected behaviour.

Check-out

Check out after check-in; verify timeOut and photo/location fields.

No check-in checkout

Attempt check-out without a same-day record and verify an understandable error response.

Leave

Submit leave and test contractor approval and rejection.

Image upload

Upload a valid image and verify returned path and file storage.

Platform connectivity

Test Flutter Web, Android emulator and physical Android device using the correct base URL.

13. Security, Reliability and Code Review Findings

The following are concrete findings from the supplied source and should be addressed before production use.

Priority

Finding

Recommended action

Critical

SecurityConfig places /**.permitAll() before specific matchers.

Remove the blanket permitAll rule; explicitly permit only public endpoints and require authentication/roles for the rest.

Critical

JWT secret and database credentials are hard-coded in application.yml.

Use environment variables or a secret manager; rotate any real secrets that may have been exposed.

High

CORS allows wildcard origins/methods/headers and credentials.

Allow only known frontend origins and required methods/headers.

High

Forgot-password flow resets password using username + phone + new password only.

Add a verified recovery challenge/OTP or trusted identity process; rate-limit attempts.

High

Labour entity stores Aadhaar number.

Minimize collection, encrypt or tokenize where appropriate, restrict access, mask in UI/logs and define retention.

High

AuthService auto-creates a labour profile when login cannot find one.

Prefer explicit onboarding and validation; avoid silently creating incomplete records with contractorId null.

High

Image upload uses original filename as part of stored name and does not show content-type/size validation in controller.

Validate MIME/type and size, normalize filenames, scan uploads and store outside public web root where possible.

Medium

AttendanceService overwrites same-day timeIn on repeated check-in.

Reject duplicate check-ins or preserve audit history.

Medium

LocationService returns fixed Delhi coordinates when location fails.

Return an explicit failure/null result instead of false coordinates; do not record fallback coordinates as real attendance.

Medium

ApiService token is held only in static memory.

Use secure persistent storage on mobile and clear token on logout/expiry.

Medium

ApiService calls /api/user/{id}, but no matching controller appears in archive.

Implement the endpoint or update the client to an existing profile endpoint.

Medium

CameraService stores photos in a temporary local directory.

Ensure the file is uploaded before storing its path in backend; temporary files may not be durable or accessible to server.

Medium

Attendance status/duration calculation is absent from the supplied check-out service.

Implement and test the business rules if full-day/half-day/overtime is a requirement.

Low

backend LocationService.java and frontend attendance_service.dart are empty.

Remove unused placeholders or implement/document their responsibilities.

Additional production considerations: use HTTPS, add request validation and consistent error responses, enforce ownership checks so one contractor cannot access another contractor's labour records, add audit logs, use database migrations, and configure backups/monitoring.

14. Known Limitations of the Supplied Archive

No SQL schema export or sample database seed data is included.

No screenshots or user manual are included in the archive.

No deployment configuration (Docker, cloud infrastructure or production profile) is established by the supplied source.

No complete end-to-end test results are included.

The README gives only a high-level summary; detailed requirements and acceptance criteria are not supplied.

The archive contains generated build/IDE files in addition to source code; these should be excluded from a clean source release.

15. Suggested Future Enhancements

Implement role-based authorization for every contractor and labour endpoint.

Add a complete contractor onboarding flow and explicit labour-to-user account linking.

Implement attendance duration calculation and configurable full-day/half-day/overtime rules.

Add attendance history filters by date, contractor and labourer.

Add reliable photo upload integration and secure image access.

Improve location failure handling and optionally show map-based attendance locations.

Complete payment calculation, payment entry, payment history and downloadable payslips.

Add notifications for leave decisions and attendance events.

Add pagination, search and filtering for large labour lists.

Add automated backend integration tests and Flutter widget tests.

Add audit trails for attendance edits, leave decisions and payment changes.

16. Conclusion

Hazari is structured as a Flutter + Spring Boot + MySQL labour-management application. The supplied source demonstrates core account, labour, attendance, leave, image-upload and payment-summary components. The main architecture is understandable and modular, but security configuration, environment secrets, location fallback behaviour, client/server route consistency and unfinished business rules require attention before the application is considered production-ready.

Appendix A — Main source files reviewed

Backend: AuthController, LabourController, ContractorController, ImageUploadController.

Backend config: SecurityConfig, JwtAuthenticationFilter, JwtUtil, ImageStorageConfig.

Backend domain: User, Contractor, Labour, Attendance, Leave, Payment.

Backend services: AuthService, AttendanceService, ContractorService, LeaveService, PaymentService, UserDetailsServiceImpl.

Frontend: main.dart; screens for login, registration, dashboards, attendance, leave, payment, labour creation and forgot password.

Frontend services: api_service.dart, camera_service.dart, location_service.dart.

Frontend models: user.dart, attendance.dart, leave.dart, payment.dart.

Hazari App • Source-code review • 31 October 2026
