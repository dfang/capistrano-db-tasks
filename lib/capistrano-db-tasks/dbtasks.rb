require File.expand_path("#{File.dirname(__FILE__)}/util")
require File.expand_path("#{File.dirname(__FILE__)}/database")
require File.expand_path("#{File.dirname(__FILE__)}/asset")

set :local_rails_env, ENV['RAILS_ENV'] || 'development' unless fetch(:local_rails_env)
set :rails_env, 'production' unless fetch(:rails_env)
set :db_local_clean, false unless fetch(:db_local_clean)
set :assets_dir, 'system' unless fetch(:assets_dir)
set :local_assets_dir, 'public' unless fetch(:local_assets_dir)

namespace :db do
  namespace :remote do
    desc 'Synchronize your remote database using local database data'
    task :sync do
      on roles(:db) do
        if Util.prompt 'Are you sure you want to REPLACE THE REMOTE DATABASE with local database'
          Database.local_to_remote(self)
        end
      end
    end
  end

  namespace :local do
    desc 'Synchronize your local database using remote database data'
    task :sync do
      on roles(:db) do
        puts "Local database: #{Database::Local.new(self).database}"
        if Util.prompt 'Are you sure you want to erase your local database with server database'
          Database.remote_to_local(self)
        end
      end
    end
  end

  desc 'Synchronize your local database using remote database data'
  task :pull => "db:local:sync"

  desc 'Synchronize your remote database using local database data'
  task :push => "db:remote:sync"
end

namespace :assets do
  namespace :remote do
    desc 'Synchronize your remote assets using local assets'
    task :sync do
      on roles(:app) do
        puts "Assets directories: #{fetch(:assets_dir)}"
        if Util.prompt "Are you sure you want to erase your server assets with local assets"
          Asset.local_to_remote(self)
        end
      end
    end
  end

  namespace :local do
    desc 'Synchronize your local assets using remote assets'
    task :sync do
      on roles(:app) do
        puts "Assets directories: #{fetch(:local_assets_dir)}"
        if Util.prompt "Are you sure you want to erase your local assets with server assets"
          Asset.remote_to_local(self)
        end
      end
    end
  end

  desc 'Synchronize your local assets using remote assets'
  task :pull => "assets:local:sync"

  desc 'Synchronize your remote assets using local assets'
  task :push => "assets:remote:sync"
end

namespace :app do
  namespace :remote do
    desc 'Synchronize your remote assets AND database using local assets and database'
    task :sync do
      if Util.prompt "Are you sure you want to REPLACE THE REMOTE DATABASE AND your remote assets with local database and assets(#{fetch(:assets_dir)})"
        Database.local_to_remote(self)
        Asset.local_to_remote(self)
      end
    end
  end

  namespace :local do
    desc 'Synchronize your local assets AND database using remote assets and database'
    task :sync do
      puts "Local database     : #{Database::Local.new(self).database}"
      puts "Assets directories : #{fetch(:local_assets_dir)}"
      if Util.prompt "Are you sure you want to erase your local database AND your local assets with server database and assets(#{fetch(:assets_dir)})"
        Database.remote_to_local(self)
        Asset.remote_to_local(self)
      end
    end
  end

  desc 'Synchronize your local assets AND database using remote assets and database'
  task :pull => "app:local:sync"

  desc 'Synchronize your remote assets AND database using local assets and database'
  task :push => "app:remote:sync"
end
