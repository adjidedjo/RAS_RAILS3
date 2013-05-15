# config/deploy.rb
require 'rvm/capistrano'  # Add RVM integration
require 'bundler/capistrano'  # Add Bundler integration
load 'deploy/assets'

set :assets_role, [:web, :app]
set :application, "elitemarketing"
role :web, "192.168.101.195"  # Your HTTP server, Apache/etc
role :app, "192.168.101.195"  # This may be the same as your `Web` server
role :db,  "192.168.101.195", :primary => true  # This is where Rails migrations will run

set :scm, :git
set :repository, "git@github.com:adjidedjo/RAS_RAILS3.git"
set :branch, "master"

set :user, "marketing"
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

namespace :deploy do
  desc "Tell Passenger to restart the app."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
