require_relative "lib/rails/maintenance/version"

Gem::Specification.new do |spec|
  spec.name        = "rails-maintenance"
  spec.version     = Rails::Maintenance::VERSION
  spec.authors     = ["Paul Belt"]
  spec.email       = ["paul.belt@corestrengths.com"]
  spec.homepage    = "https://github.com/belt/rails-maintenance"
  spec.summary     = "Summary of Rails::Maintenance."
  spec.description = "DO: Description of Rails::Maintenance."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = ""

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/belt/rails-maintenance/tree/v0.0.1/rails-maintenance"
  spec.metadata["changelog_uri"] = "https://github.com/belt/rails-maintenance/blob/v0.0.1/rails-maintenance/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.4", ">= 6.1.4.1"
end
