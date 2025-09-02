# Arabot - SWE Assessment Task

## Software Engineer Challenge
**Task Management API**

### Overview
The application should allow users to manage projects and tasks in a collaborative environment.  
Each user can create projects, add tasks to those projects, and update the status of tasks as work progresses.  
Projects can only be deleted by administrators, but normal users should be able to request a deletion, which will notify the admin to take action.  

If there’s more than one user and each user created different projects, make sure that users can add tasks to a project ONLY if:
- The project belongs to them, OR
- They have permission to the project, OR
- The project is set to public or shared.

Users should also be able to export all tasks of a project into a **cleanly formatted CSV file**.

The API must:
- Expose endpoints that follow RESTful conventions
- Return JSON responses
- Prioritize clarity, maintainability, and Rails best practices

---

### Tech Requirements
- Ruby >= 3.3.3  
- Rails 7+  
- PostgreSQL  
- Implement APIs only  
- Follow RESTful conventions  
- Secure all endpoints  

---

### Deliverables
Submit a **public GitHub repository** containing:

1. The code including **unit tests**
2. `README.md` including:
   - API documentation
   - Setup instructions
   - How to run the code and tests
   - Example API requests (include a Postman collection with real responses from tests)
   - Any assumptions or suggested improvements

---

### Bonus
- Add **JWT authentication** to enforce roles and permissions
- Add **pagination** for tasks (`?page=1&per=10`)

---

### Notes for Candidates
- Keep it simple but follow Rails best practices
- Admin notifications can be logged to console or Rails logger (no need for emails)
- Include a `seed.rb` file to populate the database with test data
- Bonus points for:
  - Clean commit history
  - Well-structured tests
  - Well-documented README

---

This task is designed to assess your ability to analyze functionalities and implement a system to achieve a specific outcome.  
By completing this challenge, you will demonstrate your proficiency as a software engineer.  

**Good Luck!**  
