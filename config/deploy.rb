# frozen_string_literal: true

set :application, 'shroom'
set :repo_url, 'https://github.com/sul-dlss-labs/SHROOM.git'

# Default branch is :main
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, "/opt/app/shroom/#{fetch(:application)}"

# Manage sneakers via systemd (from dlss-capistrano gem)
# set :sneakers_systemd_role, :worker
# set :sneakers_systemd_use_hooks, true

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w[config/database.yml]

# Default value for linked_dirs is []
set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system]

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Namespace crontab entries by application and stage
set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }
set :whenever_roles, [:scheduler]

set :passenger_roles, :web
set :rails_env, 'production'

set :sidekiq_systemd_role, :worker
set :sidekiq_systemd_use_hooks, true

# Run db migrations on app servers, not db server
set :migration_role, :app

# honeybadger_env otherwise defaults to rails_env
set :honeybadger_env, fetch(:stage)

# update shared_configs before restarting app
# before 'deploy:restart', 'shared_configs:update'

# configure capistrano-rails to work with propshaft instead of sprockets
# (we don't have public/assets/.sprockets-manifest* or public/assets/manifest*.*)
set :assets_manifests, lambda {
  [release_path.join('public', fetch(:assets_prefix), '.manifest.json')]
}
