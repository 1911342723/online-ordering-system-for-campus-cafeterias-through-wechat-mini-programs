# Campus Canteen Admin Panel

This is the Admin Panel for the Campus Canteen Ordering System, built with **Vue 3**, **Vite**, and **Element Plus**.

## Project Structure

```
frontend/admin/
  ├── src/
  │   ├── api/           # API requests
  │   ├── assets/        # Static assets
  │   ├── layout/        # Main layout (Sidebar, Header)
  │   ├── router/        # Vue Router config
  │   ├── styles/        # Global styles
  │   ├── views/         # Page components (Login, Dashboard, etc.)
  │   ├── App.vue        # Root component
  │   └── main.js        # Entry point
  ├── index.html         # HTML entry
  ├── package.json       # Dependencies
  └── vite.config.js     # Vite configuration
```

## Setup Instructions

1.  **Navigate to the admin directory**:
    ```bash
    cd frontend/admin
    ```

2.  **Install Dependencies**:
    ```bash
    npm install
    ```

3.  **Run Development Server**:
    ```bash
    npm run dev
    ```
    The application will start at `http://localhost:3000` (or another port if 3000 is busy).

## Backend Connection

The project is configured to proxy API requests starting with `/api` to `http://localhost:8080` (your SpringBoot backend).
Ensure your backend is running before logging in.

- **Login Credentials**: Use the employee credentials stored in your database (e.g., `admin` / `123456`).

## Features (Implemented)
- **Login**: Secure login with backend integration.
- **Layout**: Responsive sidebar and header.
- **Dashboard**: Basic stats view.
- **Placeholders**: Structure for Member, Category, Food, and Order management.

## Next Steps
- Implement the full CRUD logic for Member, Category, Food, and Order views using the `src/api` pattern.

