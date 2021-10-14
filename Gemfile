git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.5'

# Specify your gem's dependencies in rails-maintenance.gemspec.
gemspec

group :development do
  gem 'sqlite3'
end

group :development, :test do
  # developer support
  gem 'byebug'
  gem 'rspec'
end
