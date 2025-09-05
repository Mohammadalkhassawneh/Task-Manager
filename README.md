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

## Complete API Endpoints

### Authentication
- `POST /api/v1/auth/register` — Register new user
- `POST /api/v1/auth/login` — Login user and get JWT token

### Users
- `GET /api/v1/users/me` — Get current user profile
- `GET /api/v1/users` — List all users (admin only)
- `GET /api/v1/users/:id` — Get user by ID
- `PUT /api/v1/users/:id` — Update user profile

### Projects
- `GET /api/v1/projects` — List accessible projects (pagination: `?page=1&per=10`)
- `POST /api/v1/projects` — Create new project
- `GET /api/v1/projects/:id` — Get project details
- `PUT /api/v1/projects/:id` — Update project
- `DELETE /api/v1/projects/:id` — Delete project (admin only)
- `GET /api/v1/projects/:id/export_tasks` — Export project tasks as CSV

### Tasks
- `GET /api/v1/tasks` — Get current user's tasks (filters: `?status=pending&priority=high&page=1&per=10`)
- `POST /api/v1/projects/:project_id/tasks` — Create task in project
- `GET /api/v1/projects/:project_id/tasks/:id` — Get task details
- `PUT /api/v1/projects/:project_id/tasks/:id` — Update task
- `DELETE /api/v1/projects/:project_id/tasks/:id` — Delete task

### Project Permissions
- `GET /api/v1/projects/:project_id/project_permissions` — List project permissions
- `POST /api/v1/projects/:project_id/project_permissions` — Grant user access to project
- `GET /api/v1/projects/:project_id/project_permissions/:id` — Get permission details
- `DELETE /api/v1/projects/:project_id/project_permissions/:id` — Remove user access

### Deletion Requests
- `GET /api/v1/deletion_requests` — List all deletion requests (admin only)
- `GET /api/v1/deletion_requests/my_requests` — Get current user's deletion requests
- `POST /api/v1/projects/:project_id/deletion_requests` — Request project deletion
- `GET /api/v1/deletion_requests/:id` — Get deletion request details
- `PUT /api/v1/deletion_requests/:id` — Update/approve deletion request (admin only)
- `DELETE /api/v1/deletion_requests/:id` — Cancel deletion request

## Query Parameters & Filters

### Pagination (most list endpoints)
- `?page=1` — Page number (default: 1)
- `?per=10` — Items per page (default: 10)

### Tasks Filtering
- `?status=pending|in_progress|completed|cancelled` — Filter by status
- `?priority=low|medium|high|urgent` — Filter by priority
- `?project_id=123` — Filter by project

### Example Usage
```bash
# Get pending tasks with pagination
GET /api/v1/tasks?status=pending&page=1&per=5

# Create a new project
POST /api/v1/projects
{
  "project": {
    "name": "Website Redesign",
    "description": "Complete redesign of company website",
    "visibility": "shared"
  }
}

# Grant project access
POST /api/v1/projects/123/project_permissions
{
  "project_permission": {
    "user_id": 456,
    "permission_type": "read_write"
  }
}
```

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
- Project visibility levels: `private_access`, `shared`, `public_access`
- Task statuses: `pending`, `in_progress`, `completed`, `cancelled`
- Task priorities: `low`, `medium`, `high`, `urgent`
- User roles: `user`, `admin`
- Permission types: `read_only`, `read_write` (for project permissions)
- All responses include appropriate HTTP status codes and error messages
- Pagination responses include metadata: `current_page`, `per_page`, `total_pages`, `total_count`

