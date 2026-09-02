# BookSwap Architecture & System Overview

This document describes the architectural design, data flow, state management, and API design of the BookSwap application platform.

---

## Architecture Overview

BookSwap follows a client-server architecture:
- **Mobile Frontend**: Built using Flutter with declarative UI components, Riverpod for state management, and Dio for asynchronous HTTP request handling.
- **Backend Service**: Built with Node.js and Express.js, exposing RESTful endpoints for authentication, user administration, book catalog management, and swap request processing.
- **Database Layer**: MongoDB managed via Mongoose schemas to store persistent user records, book details, and swap request statuses.

```
+------------------------+             HTTP / REST             +------------------------+
|    Flutter Mobile      | <---------------------------------> |   Node.js / Express    |
|   (Riverpod + Dio)     |           Bearer Token              |        Backend         |
+------------------------+                                     +------------------------+
                                                                           |
                                                                           v
                                                                +----------------------+
                                                                |   MongoDB Database   |
                                                                +----------------------+
```

---

## Frontend Architecture

The Flutter application is structured in a feature-oriented layout within `Frontend/lib/`:

- **Core Layer (`lib/core/`)**:
  - `dio_client.dart`: Singleton HTTP client managing JWT header injection, interceptors, and automated token invalidation on `401 Unauthorized` responses.

- **State Management Layer (`lib/providers/`)**:
  - `auth_provider.dart`: Manages authentication state, user session tokens using `SharedPreferences`, login, and registration workflows.
  - `admin_provider.dart`: Coordinates administrative actions such as user listing, user deletion, role updates, and system metrics fetching.

- **UI Layer (`lib/*.dart`)**:
  - **Auth Views**: `welcome_page.dart`, `login_page.dart`, `signup_page.dart`, `change_password_page.dart`.
  - **User Portal**: `home_page.dart`, `book_detail_page.dart`, `add_books_page.dart`, `edit_book_page.dart`, `my_book_list_page.dart`, `my_swap_request_page.dart`, `profile_page.dart`, `edit_profile_page.dart`.
  - **Admin Portal**: `admin_auth_page.dart`, `admin_dashboard_page.dart`, `admin_profile_page.dart`, `add_user_page.dart`.

---

## Backend Schema Models

### Book Schema (`backend/models/books.js`)

| Field | Type | Required | Description |
|---|---|---|---|
| `title` | String | Yes | Title of the book |
| `author` | String | Yes | Book author |
| `genre` | String | Yes | Literary genre / category |
| `photo` | String | Yes | URL / path to cover image |
| `pdf_file` | String | No | URL / path to optional digital PDF |
| `language` | String | No | Language of the publication |
| `edition` | String | No | Edition release information |
| `description` | String | No | Brief summary or condition notes |
| `owner` | ObjectId (`User`) | Yes | Reference to the user who listed the book |
| `timestamps` | Date | Auto | `createdAt` and `updatedAt` records |

---

## Authentication & Security

1. **Tokens**: JWT Bearer tokens are issued upon successful authentication and stored securely in local storage (`SharedPreferences`).
2. **Interceptors**: Dio automatically injects `Authorization: Bearer <token>` in HTTP headers for protected routes.
3. **Password Security**: Passwords are hashed using `bcrypt` before storage in MongoDB.
