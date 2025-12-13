# Task Management App

A simple task management app for gig workers that allows users to create, update, delete, and view tasks. Built with Flutter and Firebase, this project follows Clean Architecture principles and uses Riverpod for state management.

## Features

- **User Authentication**: Secure sign-up and login with email/password and Google Sign-In via Firebase Authentication.
- **Task Management (CRUD)**: Create, read, update, and delete tasks with ease.
- **Task Properties**: Each task includes a title, description, due date, and priority level (low, medium, high).
- **Task Status**: Mark tasks as complete or incomplete to track your progress.
- **Filtering and Sorting**: Filter tasks by priority and status, with all tasks automatically sorted by their due date.
- **Clean UI**: A responsive and intuitive user interface built with Material Design principles.

## Screenshots

*(Add your screenshots here)*

## Architecture

This project follows the principles of **Clean Architecture**, separating the codebase into three distinct layers:

- **Data Layer**: Handles data sources, such as Firebase Firestore, and implements the repositories defined in the domain layer.
- **Domain Layer**: Contains the core business logic, including entities, use cases, and repository contracts.
- **Presentation Layer**: Manages the UI and state using Flutter and Riverpod. It includes all the screens, widgets, and providers.

## Technologies Used

- **Framework**: Flutter
- **Backend**: Firebase (Authentication, Firestore)
- **State Management**: Riverpod
- **Icons**: Font Awesome Flutter
- **Date Formatting**: intl
- **Unique IDs**: uuid
- **Value Equality**: equatable

## Setup and Installation

1.  **Clone the repository**:
    ```sh
    git clone <repository-url>
    ```
2.  **Set up Firebase**:
    - Create a new Firebase project.
    - Add your Android app to the project and download the `google-services.json` file.
    - Place the `google-services.json` file in the `android/app` directory.
    - In the Firebase console, enable **Email/Password** and **Google** sign-in methods.
    - Generate and add the **SHA-1 fingerprint** for Google Sign-In to work correctly.
3.  **Install dependencies**:
    ```sh
    flutter pub get
    ```
4.  **Run the app**:
    ```sh
    flutter run
    ```

