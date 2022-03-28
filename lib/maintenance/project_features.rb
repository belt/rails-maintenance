# frozen_string_literal: true

require 'active_support/configurable'
require_relative './options'
require_relative './base'
require_relative './database'

# require Rails.root.join('lib', 'maintenance', 'project_features')
module Maintenance
  # supports_features: capture a set of product-features a given model supports
  #
  # This provides a data-structure for machina to easily identify which data
  # are belonging to which feature for the purposes of application maintenance
  # and operations through meta-programming.
  #
  # TL;DR =~ Hey developer, these data are related,, independent of NameSpaces
  #
  # To add "features" to a model, use the following pattern
  #   class << self
  #     # NOTE: must yield config.supports_features as a matter of DSL
  #     def features
  #       %i(some_feature generally_approved_by product_people)
  #     end
  #   end
  class ProjectFeatures
    include ActiveSupport::Configurable
    config_accessor :features
    config.features = ::Maintenance::Options.config.features

    class << self
      # e.g. ::Maintenance::ProjectFeatures.models_supporting_features
      #
      # :reek:ManualDispatch
      def models_supporting_features
        # initialize supported_features map
        ::Maintenance::Base.eager_load_namespaces
        ::Maintenance::Database.filtered_descendants.select { |model|
          model.respond_to?(:supports_features)
        }.map(&:supports_features)

        # report findings
        ApplicationRecord.config.supports_features
      end

      # e.g. ::Maintenance::ProjectFeatures.featured_table_names
      def featured_table_names(features: nil)
        featured_descendants(features: features).map(&:table_name)
      end

      # e.g. ::Maintenance::ProjectFeatures.non_featured_table_names
      def non_featured_table_names(features: nil)
        ::Maintenance::Database.tabled_descendants.map(
          &:table_name
        ) - featured_table_names(features: features)
      end

      # reject those not supporting features under scrutiny
      # reject models not supporting selected FEATURES
      # e.g. ::Maintenance::ProjectFeatures.featured_descendants
      def featured_descendants(features: nil)
        features ||= ::Maintenance::Options.config.features

        featured = ::Maintenance::Database.filtered_descendants.reject do |model|
          !model.respond_to?(:supports_features) ||
            (features.map(&:to_s) & model.supports_features.keys.map(&:to_s)).empty?
        end
        return ::Maintenance::Database.tabled_descendants if featured.empty?

        featured
      end
    end
  end
end
