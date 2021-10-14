# frozen_string_literal: true

require 'active_record/type'
require 'csv'
require 'io/console'

# Collection of handy maintenace tasks
module Maintenance
  # convenience feature
  #
  # casts ENV variables into ruby constants with defaults, validation, etc
  # prompt for a password on the CLI and mask the IO
  class Options
    FEATURES = Array(
      begin
        CSV.parse(ENV['FEATURES'].to_s.downcase)
      rescue ArgumentError, NoMethodError => _e
        ::Maintenance::Database.tabled_descendants.select do |model|
          model.respond_to?(:supports_features)
        end.map(&:supports_features).flat_map(&:keys).uniq.sort
      end
    ).flatten.sort.uniq.freeze

    VERBOSE = lambda {
      ActiveRecord::Type::Boolean.new.cast(ENV['VERBOSE'])
    }.call.freeze

    VERBOSE_LEVEL = lambda {
      ActiveRecord::Type::Integer.new.cast(ENV['VERBOSE']) || 0
    }.call.freeze

    class << self
      def password_from_prompt(prompt: 'password: ')
        IO.console.getpass(prompt)
      end
    end
  end
end
