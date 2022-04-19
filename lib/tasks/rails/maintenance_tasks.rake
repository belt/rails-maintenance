# frozen_string_literal: true

namespace :maintenance do
  desc 'rails tmp:clear log:clear # etc'
  task :purge, %(cache) => %i(environment) do |_task, args|
    rails_root = Rails.root
    Pry::ColorPrinter.pp('clearing tmp/' => rails_root.join('tmp').to_s)
    Rake::Task('tmp:clear').invoke

    Pry::ColorPrinter.pp('clearing log/' => rails_root.join('log').to_s)
    Rake::Task('log:clear').invoke

    if args[:bootsnap]
      bootsnap_path = ENV['BOOTSNAP_CACHE_DIR'] || rails_root.join('bootsnap_cache').to_s
      Pry::ColorPrinter.pp("clearing #{bootsnap_path}")
      Dir.glob(path) do |sub_path|
        FileUtils.remove_dir(sub_path) if Dir.exist?(sub_path)
      end
    end

    Pry::ColorPrinter.pp('maintenance:purge complete')
  end

  namespace :features do
    desc [
      'Enumerate FEATURES options',
      'i.e. supported features for all table-backed, non-filtered, ActiveRecord::Base descendants'
    ].join(' ')
    task :list, %() => %i(environment) do |_task, args|
      features = Maintenance::ProjectFeatures.models_supporting_features.keys.sort

      Pry::ColorPrinter.pp({ FEATURES: features })
    end

    desc [
      'Enumerate FEATURED models',
      'i.e. non-filtered models supporting relevant features'
    ].join(' ')
    task :featured_models, %() => %i(environment) do |_task, args|
      features = Maintenance::ProjectFeatures.models_supporting_features.keys.sort
      sorted_hash = features.each_with_object({}) { |key, acc|
        acc[key] = Maintenance::ProjectFeatures.models_supporting_features[key].sort
        acc
      }.with_indifferent_access

      Pry::ColorPrinter.pp({ FEATURED_MODELS: sorted_hash })
    end

    desc [
      'Enumerate FEATURED table names',
      'i.e. non-filtered table names supported relevant features'
    ].join(' ')
    task :featured_tables, %() => %i(environment) do |_task, args|
      featured_tables = Maintenance::ProjectFeatures.featured_table_names

      Pry::ColorPrinter.pp({ FEATURED_TABLES: featured_tables })
    end
  end
end
