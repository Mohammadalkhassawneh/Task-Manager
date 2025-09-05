# Clear existing data
puts "Clearing existing data..."
DeletionRequest.destroy_all
Task.destroy_all
ProjectPermission.destroy_all
Project.destroy_all
User.destroy_all

puts "Creating users..."

# Create admin user
User.create!(
  name: "Admin User",
  email: "admin@example.com",
  password: "password123",
  role: "admin"
)

# Create regular users
user1 = User.create!(
  name: "John Doe",
  email: "john@example.com",
  password: "password123",
  role: "user"
)

user2 = User.create!(
  name: "Jane Smith",
  email: "jane@example.com", 
  password: "password123",
  role: "user"
)

user3 = User.create!(
  name: "Bob Johnson",
  email: "bob@example.com",
  password: "password123", 
  role: "user"
)

puts "Creating projects..."

# Projects for user1
project1 = Project.create!(
  name: "Website Redesign",
  description: "Complete redesign of the company website with modern UI/UX",
  visibility: "public_access",
  user: user1
)

project2 = Project.create!(
  name: "Mobile App Development", 
  description: "Development of a new mobile application for iOS and Android",
  visibility: "shared",
  user: user1
)

project3 = Project.create!(
  name: "Personal Blog",
  description: "A personal blog project for sharing thoughts and ideas",
  visibility: "private_access",
  user: user1
)

# Projects for user2
project4 = Project.create!(
  name: "E-commerce Platform",
  description: "Building a comprehensive e-commerce solution",
  visibility: "shared",
  user: user2
)

project5 = Project.create!(
  name: "Marketing Campaign",
  description: "Planning and execution of Q4 marketing campaigns",
  visibility: "public_access",
  user: user2
)

puts "Creating project permissions..."

# Give user2 permission to user1's shared project
ProjectPermission.create!(
  project: project2,
  user: user2,
  permission_type: "write"
)

# Give user3 permission to user2's shared project
ProjectPermission.create!(
  project: project4,
  user: user3,
  permission_type: "read"
)

puts "Creating tasks..."

# Tasks for Website Redesign (project1)
Task.create!(
  title: "Design Homepage Mockup",
  description: "Create wireframes and mockups for the new homepage design",
  status: "completed",
  priority: "high",
  due_date: 1.week.ago,
  project: project1,
  user: user1
)

Task.create!(
  title: "Implement Responsive Layout",
  description: "Code the responsive layout based on approved designs",
  status: "in_progress", 
  priority: "high",
  due_date: 3.days.from_now,
  project: project1,
  user: user1
)

Task.create!(
  title: "Content Migration",
  description: "Migrate existing content to the new website structure",
  status: "pending",
  priority: "medium",
  due_date: 1.week.from_now,
  project: project1,
  user: user2
)

# Tasks for Mobile App (project2)
Task.create!(
  title: "Setup Development Environment",
  description: "Configure React Native development environment",
  status: "completed",
  priority: "urgent",
  due_date: 2.weeks.ago,
  project: project2,
  user: user1
)

Task.create!(
  title: "Design App Navigation",
  description: "Create the main navigation structure for the mobile app",
  status: "in_progress",
  priority: "high", 
  due_date: 5.days.from_now,
  project: project2,
  user: user2
)

Task.create!(
  title: "Implement User Authentication",
  description: "Add user login and registration functionality",
  status: "pending",
  priority: "high",
  due_date: 2.weeks.from_now,
  project: project2,
  user: user1
)

# Tasks for E-commerce Platform (project4)
Task.create!(
  title: "Database Schema Design",
  description: "Design the database schema for products, orders, and users",
  status: "completed",
  priority: "urgent",
  due_date: 1.week.ago,
  project: project4,
  user: user2
)

Task.create!(
  title: "Product Catalog Implementation",
  description: "Build the product browsing and search functionality",
  status: "in_progress",
  priority: "high",
  due_date: 10.days.from_now,
  project: project4,
  user: user3
)

Task.create!(
  title: "Payment Gateway Integration",
  description: "Integrate Stripe payment processing",
  status: "pending",
  priority: "medium",
  due_date: 3.weeks.from_now,
  project: project4,
  user: user2
)

puts "Creating deletion requests..."

# Create a deletion request for testing
DeletionRequest.create!(
  project: project3,
  user: user1,
  reason: "Project is no longer needed and taking up space",
  status: "pending"
)

# Create an approved deletion request (for testing purposes)
DeletionRequest.create!(
  project: project5,
  user: user2,
  reason: "Duplicate project created by mistake",
  status: "approved",
  admin_notes: "Approved by admin. Project was indeed a duplicate."
)

puts "Seed data created successfully!"
puts "\nSummary:"
puts "- #{User.count} users created (1 admin, 3 regular users)"
puts "- #{Project.count} projects created"
puts "- #{ProjectPermission.count} project permissions created"
puts "- #{Task.count} tasks created"
puts "- #{DeletionRequest.count} deletion requests created"

puts "\nTest credentials:"
puts "Admin: admin@example.com / password123"
puts "User 1: john@example.com / password123"
puts "User 2: jane@example.com / password123"
puts "User 3: bob@example.com / password123"
