# Task Management API

A lightweight Task Management API built with Ruby on Rails. Provides user authentication (JWT), project and task management, role-based access (admin/user), and CSV export.

Quick links
- API base: `http://localhost:3000/api/v1`
- **Swagger UI**: `http://localhost:3000/api-docs`
- Postman collection: `postman/Task_Management_API.postman_collection.json`

Prerequisites
- Ruby 3.3+, Rails 7.2+, PostgreSQL

Setup
1. Install dependencies
   ```bash
   bundle install
   ```
2. Database
   ```bash
   rails db:create db:migrate db:seed
   ```
3. Start server
   ```bash
   rails server
   ```

Run tests
```bash
bundle exec rspec
```

Authentication
- Use `POST /api/v1/auth/register` to create a user (role: `user` or `admin`).
- Use `POST /api/v1/auth/login` to receive a JWT token.
- Include token in requests: `Authorization: Bearer <token>`

Common Endpoints (summary)
- Users
  - `GET /api/v1/users/me` — current user
  - `GET /api/v1/users` — all users (admin only)
  - `PUT /api/v1/users/:id` — update
- Projects
  - `GET /api/v1/projects` — list (pagination: `?page=&per=`)
  - `POST /api/v1/projects` — create
  - `GET/PUT/DELETE /api/v1/projects/:id`
  - `GET /api/v1/projects/:id/export_tasks` — CSV export
- Tasks
  - `GET /api/v1/tasks` — current user's tasks (filters supported)
  - `POST /api/v1/projects/:project_id/tasks` — create task
  - `GET/PUT/DELETE /api/v1/projects/:project_id/tasks/:id`
- Permissions & Deletion Requests
  - Manage project permissions and deletion requests (admin flows exist)

Postman
Import the collection and environment from the `postman/` folder. Tokens are auto-extracted.

Swagger Documentation
Interactive API documentation is available at `http://localhost:3000/api-docs` when the server is running.
- Browse all endpoints with request/response examples
- Test API calls directly from the browser
- View detailed schema definitions
- JWT authentication supported in the UI

Notes
- JWT tokens are stateless and expire per server config.
- Admin-only actions return `401 Unauthorized` for non-admins.

