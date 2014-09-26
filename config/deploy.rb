# $:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm'
require 'rvm/capistrano'
require 'bundler/capistrano'
require 'puma/capistrano'

set :application, "ads"
set :rails_env, "production"
set :ssh_ip, "83.222.73.240"
set :ssh_port, 1204
set :ssh_username, "slon"
set :default_run_options, {:pty => true}
ssh_options[:port] = ssh_port
set :domain, "#{ssh_username}@#{ssh_ip}"
set :deploy_to, "/home/slon/projects/#{application}"
set :use_sudo, false

set :rvm_type, :user

set :scm, :git
set :repository,  "ssh://git@#{ssh_ip}:#{ssh_port}/home/git/#{application}.git"
set :branch, "master"
set :deploy_via, :remote_cache

role :web, domain
role :app, domain
role :db,  domain, :primary => true

before "deploy:restart", "deploy:migrate"

namespace :deploy do

  task :create_db do
    run "cd #{deploy_to}/current; bundle exec rake db:create RAILS_ENV=#{rails_env}"
  end

  task :migrate do
    run "cd #{deploy_to}/current; bundle exec rake db:migrate RAILS_ENV=#{rails_env}"
  end

  task :symlink_config, roles: :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/shared/config/secrets.yml #{release_path}/config/secrets.yml"
    run "ln -nfs #{deploy_to}/shared/config/puma.rb #{release_path}/config/puma.rb"
    run "ln -s #{deploy_to}/shared #{release_path}"
  end

  task :assets_precompile do
    run "cd #{current_release} && RAILS_ENV=production bundle exec rake assets:precompile"
#    run "mv #{current_release}/public/assets/glyphicons-halflings-regular-*.svg #{current_release}/public/assets/glyphicons-halflings-regular.svg"
#    run "mv #{current_release}/public/assets/glyphicons-halflings-regular-*.eot #{current_release}/public/assets/glyphicons-halflings-regular.eot"
#    run "mv #{current_release}/public/assets/glyphicons-halflings-regular-*.ttf #{current_release}/public/assets/glyphicons-halflings-regular.ttf"
#    run "mv #{current_release}/public/assets/glyphicons-halflings-regular-*.woff #{current_release}/public/assets/glyphicons-halflings-regular.woff"
#    run "mv #{current_release}/public/assets/select2-*.png #{current_release}/public/assets/select2.png"
#    run "mv #{current_release}/public/assets/select2x2-*.png #{current_release}/public/assets/select2x2.png"
#    run "mv #{current_release}/public/assets/select2-spinner*.gif #{current_release}/public/assets/select2-spinner.gif"
  end

  after "deploy:finalize_update", "deploy:symlink_config", "deploy:assets_precompile", "deploy:restart"
end

