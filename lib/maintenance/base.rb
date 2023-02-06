# frozen_string_literal: true

# Collection of handy maintenance tasks when operating within a rails app
module Maintenance
  # Collection of handy rails tasks
  #
  # pry> ::Maintenance::Base.eager_load_namespaces
  class Base
    class << self
      def eager_load_namespaces
        ::Rails.configuration.eager_load_namespaces.reject { |ns|
          exclude_namespaces.include?(ns)
        }.each(&:eager_load!)
      end

      def exclude_namespaces
        [ActiveStorage::Engine]
      end

      # tables not generally a part of features
      def tables_of_aggregation
        tables = []
        tables.push PaperTrail::Version if defined?(PaperTrail::Version)
        tables.push ActsAsTaggableOn::Tag if defined?(ActsAsTaggableOn::Tag)
        tables.push ActsAsTaggableOn::Tagging if defined?(ActsAsTaggableOn::Tagging)
        tables.push ActiveRecord::SchemaMigration if defined?(ActiveRecord::SchemaMigration)
        tables.push ActiveStorage::Blob if defined?(ActiveStorage::Blob)
        tables.push ActionText::RichText if defined?(ActionText::RichText)
        tables.push ActionMailbox::InboundEmail if defined?(ActionMailbox::InboundEmail)
        tables
      end
    end
  end
end
