# config valid only for current version of Capistrano
lock '3.18.1'

set :application, 'haiban_sit_demo'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/usr/local/app_root/haiban_sit_demo/webapp'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/assets public/system public/packs .bundle node_modules}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH",rvmsudo_secure_path: 1 }
set :bundle_jobs, 4

# Default value for keep_releases is 5
# set :keep_releases, 5

set :user, "web"
set :god_comand, '/usr/local/bin/god'

before "deploy:assets:precompile", "deploy:yarn_install"
namespace :deploy do
  #desc "Run rake yarn install"
  task :yarn_install do
    on roles(:web) do
      within release_path do
        # execute "export N_PREFIX=$HOME/.n && export PATH=$N_PREFIX/bin:$PATH && cd #{release_path} && yarn install --silent --no-progress --no-audit --no-optional "
        execute "cd #{release_path} && yarn install --silent --no-progress --no-audit --no-optional "
      end
    end
  end
  task :start do
    on roles(:app) do
      execute :rvmsudo, "#{fetch(:god_comand)} start #{fetch(:application)}"
      execute :rvmsudo, "#{fetch(:god_comand)} start #{fetch(:application)}_dj"
    end
  end

  task :stop do
    on roles(:app) do
      execute :rvmsudo, "#{fetch(:god_comand)} stop #{fetch(:application)}"
      execute :rvmsudo, "#{fetch(:god_comand)} stop #{fetch(:application)}_dj"
    end
  end

  task :restart do
    on roles(:app) do
      execute :rvmsudo, "#{fetch(:god_comand)} restart #{fetch(:application)}"
      execute :rvmsudo, "#{fetch(:god_comand)} restart #{fetch(:application)}_dj"
    end
  end

  after 'deploy:publishing', 'deploy:restart'
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
  # after 'deploy:published', 'restart' do
  #   invoke 'delayed_job:restart'
  # end
end
