# frozen_string_literal: true

# HOWTO: integrate with existing rails apps
#
# Contents of `app/models/application_record.rb` should contain:
#
# ```
#   require 'maintenance/application_record_support'
#   class ApplicationRecord < ActiveRecord::Base
#     self.abstract_class = true
#
#     include ::ApplicationRecordSupport
#   end
# ```
module ApplicationRecordSupport
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      include ActiveSupport::Configurable

      config_accessor :supports_features

      # create a new set for each new hash key by passing a block
      # the default value will be the Set.new returned by the default proc
      # use block paramers in the proc to initialize the data-store for
      # supported_features e.g. ActiveSupport::HashWithIndifferentAccess
      config.supports_features = ActiveSupport::HashWithIndifferentAccess.new do |hash, key|
        hash[key] = Set.new
      end

      class << self
        def features
          %i()
        end

        def supports_features
          features.each do |feature|
            config.supports_features[feature].add(name)
          end
          # config.supports_features.select { |_feature, models| models.include?(name) }
          config.supports_features.slice(*features)
        end

        def supports_feature(feature:)
          config.supports_features.key?(feature.to_sym)
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # Class methods added to all ApplicationRecord descendants
  module ClassMethods
  end
end
