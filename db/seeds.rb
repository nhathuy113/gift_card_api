admin_email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "password123")
Admin.find_or_create_by!(email: admin_email) do |user|
  user.password = admin_password
  user.role = "admin"
  user.state = "active"
end
