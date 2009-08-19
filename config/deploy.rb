# Voigtlab server configuration
set :user, 'ktemme'  # Voigtlab account username
set :domain, 'voigtlab.ucsf.edu'  
set :destination_dir, "/var/www/ruby/tecan"


default_run_options[:pty] = true
set :repository,  "git@github-tecan:ktemme/Tecan-Analysis.git"
set :scm, "git"
set :scm_username, 'ktemme'

ssh_options[:forward_agent] = true
set :scm_branch, 'master'
set :deploy_via, :remote_cache
set :deploy_to, destination_dir
set :use_sudo, false

# Roles (servers)
role :app, domain


namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end