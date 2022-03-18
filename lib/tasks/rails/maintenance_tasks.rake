namespace :maintenance do
  desc 'rails tmp:clear log:clear # etc'
  task :purge, %(cache) => %i(environment) do |_task, args|
    rails_root = Rails.root
    Pry ColorPrinter.pp('clearing tmp/' => rails_root.join('tmp').to_s)
    Rake::Task('tmp:clear').invoke

    Pry ColorPrinter.pp('clearing log/' => rails_root.join('log').to_s)
    Rake::Task('log:clear').invoke

    if args[:bootsnap]
      bootsnap_path = ENV['BOOTSNAP_CACHE_DIR'] || rails_root.join('bootsnap_cache').to_s
      Pry ColorPrinter.pp("clearing #{bootsnap_path}")
      Dir.glob(path) do |sub_path|
        FileUtils.remove_dir(sub_path) if Dir.exists?(sub_path)
      end
    end

    Pry ColorPrinter.pp('maintenance:purge complete')
  end
end
