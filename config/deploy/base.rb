namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart do ; end

  desc "Symlink configs"
  task :symlink_configs, roles: :app do
    run "#{try_sudo} ln -nfs #{deploy_to}/shared/config/.env #{release_path}/"
    run "#{try_sudo} ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/"
    run "#{try_sudo} ln -nfs #{deploy_to}/shared/config/secrets.yml #{release_path}/config/"
  end

# Created to help with first time database creation
#  namespace :db do
#    task :setup do
#      puts "\n\n=== Setting up the Database! ===\n\n"
#      run "cd #{release_path}; bundle exec rake db:setup RAILS_ENV=#{rails_env}"
#    end
#  end
end
