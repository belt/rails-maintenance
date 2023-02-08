# frozen_string_literal: true

require 'active_support/configurable'
require_relative './options'
require_relative './base'
require_relative './database'

# require 'maintenance/project_features'
# _features = Maintenance::ProjectFeatures.models_supporting_features.keys.sort
# Maintenance::ProjectFeatures.models_supporting_features
# Maintenance::ProjectFeatures.featured_table_names(features: %w(identity authorization))
# Maintenance::ProjectFeatures.non_featured_table_names(features: %w(identity authorization)).uniq
# Maintenance::ProjectFeatures.featured_descendants(features: %w(identity authorization))
# Maintenance::ProjectFeatures.tabled_descendants_of(model: User)
# Maintenance::ProjectFeatures.humanized_tabled_descendants_of(model: User)
# Maintenance::ProjectFeatures.descendant_of?(model: User, descendant: AR::BelongsToReflection)
# Maintenance::ProjectFeatures.reflections_of(model: User)
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
        featured_descendants(features: features).map(&:table_name).map(&:to_s).uniq
      end

      # e.g. ::Maintenance::ProjectFeatures.non_featured_table_names
      def non_featured_table_names(features: nil)
        ::Maintenance::Database.filtered_descendants.map(
          &:table_name
        ).map(&:to_s).uniq - featured_table_names(features: features)
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

      # e.g. ::Maintenance::ProjectFeatures.tabled_descendants_of(model: User)
      def tabled_descendants_of(model: nil)
        tabled_reflections = tabled_models.filter_map do |descendant|
          descendant if descendant_of?(model: model, descendant: descendant)
        end
        tabled_reflections.each_with_object({}) do |descendant, acc|
          relatives = reflections_of(model: model, descendant: descendant)
          next if relatives.blank?

          acc[descendant] ||= []
          acc[descendant].push(*relatives)
        end
      end

      # e.g. ::Maintenance::ProjectFeatures.humanized_tabled_descendants_of(model: User)
      def humanized_tabled_descendants_of(model: nil)
        tabled_descendants_of(model: model).transform_values { |node|
          node.map  do |rel|
            rel == ActiveRecord::Reflection::BelongsToReflection ? "#{rel.name}_id" : rel.name
          end
        }.transform_keys(&:name)
      end

      # e.g. ::Maintenance::ProjectFeatures.descendant_of?(model: User, descendant: Reflection)
      def descendant_of?(model:, descendant:)
        filter_for = model_filter(model: model)
        return false if filter_for == descendant.name

        descendant.reflections.detect do |(_relation_name, rel)|
          rel_reflections = reflections_of(model: model, descendant: rel.active_record)
          rel_reflections.present?
        end
      end

      # e.g. ::Maintenance::ProjectFeatures.polymorphic_reflections_of(model: User)
      # TODO: search for these with `_type = 'User'` in SQL
      def polymorphic_reflections_of(model:)
        model.reflections.values.select { |rel| rel.options[:polymorphic] }
      end

      # e.g. ::Maintenance::ProjectFeatures.reflections_of(model: User)
      def reflections_of(model:, descendant:)
        filter_for = model_filter(model: model)

        descendant.reflections.values.reject { |rel| rel.options[:polymorphic] }.select do |rel|
          (
            rel.instance_of?(ActiveRecord::Reflection::BelongsToReflection) &&
            rel.name.to_s.underscore == model.name.underscore
          ) || (
            rel.options[:class_name] == filter_for
          )
        end
      end

      def model_filter(model:)
        model.respond_to?(:name) ? model.name : model.to_s.classify
      end
    end
  end
end
