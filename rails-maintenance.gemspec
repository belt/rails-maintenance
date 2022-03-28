# frozen_string_literal: true

require_relative 'lib/rails/maintenance/version'

Gem::Specification.new do |spec|
  spec.name = 'rails-maintenance'
  spec.version = ::Rails::Maintenance::VERSION
  spec.homepage = 'https://github.com/belt/rails-maintenance'

  spec.rubygems_version = '3.0.9'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.8')
  if spec.respond_to? :required_rubygems_version=
    spec.required_rubygems_version = Gem::Requirement.new('>= 3')
  end

  if spec.respond_to? :metadata=
    base_uri = "https://github.com/belt/rails-maintenance/blob/v#{spec.version}"
    meta = {
      'homepage_uri' => spec.homepage,
      'changelog_uri' => "#{base_uri}/rails-maintenance/CHANGELOG.md",
      'source_code_uri' => "#{base_uri}/rails-maintenance"
    }

    # Prevent pushing this gem to RubyGems.org. To allow pushes either set
    # the 'allowed_push_host' to allow pushing to a single host or delete
    # this section to allow pushing to any host.
    meta['allowed_push_host'] = ''

    spec.metadata = meta
  end

  spec.require_paths = ['lib']
  spec.authors = ['Paul Belt']
  spec.description = 'Collection of handy maintenance tasks when operating within a rails app'
  spec.email = ['paul.belt+github@gmail.com']
  spec.licenses = ['Apache-2.0']
  spec.summary = 'Maintenance framework for Rails.'
  spec.files = [
    # 'app/models/application_record.rb',
    'lib/maintenance/application_record_support.rb',
    'lib/maintenance/base.rb',
    'lib/maintenance/database.rb',
    'lib/maintenance/options.rb',
    'lib/maintenance/project_features.rb',
    'LICENSE',
    'SECURITY.md',
    'README.md'
  ]

  # spec.installed_by_version = "3.0.9" if spec.respond_to? :installed_by_version

  add_dependency = ->(gem_name, versions) { spec.add_dependency(gem_name, *versions) }
  add_runtime_dep = ->(gem_name, versions) { spec.add_runtime_dependency(gem_name, *versions) }
  dependency_versions_for = {
    runtime: {
      activesupport: ['>= 5.2'],
      activerecord: ['>= 5.2'],
      rake: ['>= 13.0.6']
    }.transform_keys do |key|
      key.to_sym
    rescue StandardError
      key
    end
  }.freeze

  if spec.respond_to? :specification_version
    spec.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0')
      dependency_versions_for[:runtime].each do |gem_name, versions|
        add_runtime_dep.call(gem_name, versions)
      end
    else
      dependency_versions_for[:runtime].each do |gem_name, versions|
        add_dependency.call(gem_name, versions)
      end
    end
  else
    dependency_versions_for[:runtime].each do |gem_name, versions|
      add_dependency.call(gem_name, versions)
    end
  end
end

# vim:ft=ruby
