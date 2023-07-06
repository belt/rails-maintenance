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
        tables.push ActiveRecord::SchemaMigration if table_exists_for(
          ActiveRecord::SchemaMigration
        )
        tables.push ActiveStorage::Blob if table_exists_for(ActiveStorage::Blob)
        tables.push ActionText::RichText if table_exists_for(ActionText::RichText)
        tables.push ActionMailbox::InboundEmail if table_exists_for(ActionMailbox::InboundEmail)
        tables.push PaperTrail::Version if table_exists_for(PaperTrail::Version)
        tables.push ActsAsTaggableOn::Tag if table_exists_for(ActsAsTaggableOn::Tag)
        tables.push ActsAsTaggableOn::Tagging if table_exists_for(ActsAsTaggableOn::Tagging)
        tables
      end

      # NOTE: the class may be defined, but the table may not exist
      def table_exists_for(klass)
        defined?(klass)
      rescue PG::UndefinedTable => e
      end
    end
  end
end
