source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.4"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]


# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors"

# Sign and verify login tokens
gem "jwt", "~> 2.9"
# Serve the OpenAPI file at /api-docs
gem "rswag-api", "~> 2.17"
# Swagger UI at /api-docs
gem "rswag-ui", "~> 2.17"
# rswag-ui requires ostruct; Ruby 3.4 does not load it unless declared
gem "ostruct"
# Allowlist JSON attributes so password_digest is not rendered
gem "alba", "~> 4.0"


group :development, :test do
  # CI: known vulnerable gems in Gemfile.lock
  gem "bundler-audit", require: false
  # CI: Rails security scan
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Request and model specs
  gem "rspec-rails", "~> 7.1"
  # Spec factories
  gem "factory_bot_rails"
  # Unique emails in factories
  gem "faker"
  # Validation matchers in model specs
  gem "shoulda-matchers", "~> 8.0"
end
