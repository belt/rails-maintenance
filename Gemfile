# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in rails-maintenance.gemspec.
gemspec

# frozen_string_literal: true
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.1'

# Specify your gem's dependencies in rails-maintenance.gemspec.
gemspec

# rails
gem 'activerecord'
gem 'activesupport'

# rails console
gem 'awesome_print'
gem 'bond'
gem 'interactive_editor'
gem 'pry'
gem 'pry-nav'
# gem 'pry-remote'

# data, validation, and transformations
gem 'uuid'

# uncategorized
gem 'overcommit', require: false
gem 'pronto', require: false

group :development do
  gem 'binding_of_caller'
end

group :test do
  gem 'database_cleaner', '~> 1.7.0'
end

group :development, :test do
  # developer support
  gem 'byebug'
  gem 'fasterer', require: false
  gem 'flay', require: false
  gem 'rspec'

  # ops support
  gem 'bundler-audit'

  # rspec, factory, faker patterns and support
  gem 'faker'
  gem 'faker-bot'

  # rubocop
  # NOTE: codeclimate channels only support up to 1.18.3 as of this commit
  gem 'rubocop', '~> 1.18.3'
  gem 'rubocop-faker', '~> 1.0.0'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
end
