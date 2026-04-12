set :repo_url, "git@118.103.55.206:/usr/local/gitroot/haiban_sit_demo.git"
set :branch, 'stage'
set :god_comand, "god"
set :deploy_to, "/usr/local/app_root/haiban_sit_demo_stg/webapp"
set :application, "haiban_sit_demo_stg"

rvm_home = "/home/seiko"
ruby_version = "ruby-3.2.3"
set :deploy_via, :copy

set :default_env, {
  path: "#{rvm_home}/.rvm/gems/#{ruby_version}/bin:#{rvm_home}/.rvm/gems/#{ruby_version}@global/bin:#{rvm_home}/.rvm/rubies/#{ruby_version}/bin:#{rvm_home}/.rvm/gems/#{ruby_version}/bin:#{rvm_home}/.rvm/gems/#{ruby_version}@global/bin:#{rvm_home}/.rvm/rubies/#{ruby_version}/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:#{rvm_home}/.rvm/bin:#{rvm_home}/.local/bin:#{rvm_home}/bin",
  gem_home: "#{rvm_home}/.rvm/gems/#{ruby_version}",
  gem_path: "#{rvm_home}/.rvm/gems/#{ruby_version}:#{rvm_home}/.rvm/gems/#{ruby_version}@global",
  my_ruby_home: "#{rvm_home}/.rvm/rubies/#{ruby_version}",
  irbrc: "#{rvm_home}/.rvm/rubies/#{ruby_version}/.irbrc",
  ruby_version: "#{ruby_version}",
  node_options: "--openssl-legacy-provider",
  rvmsudo_secure_path: 1
}
append :linked_files, 'config/database.yml', 'config/master.key'

set :user, "seiko"
set :password, "hitachi"

role :web, %w[210.191.73.183]
role :app, %w[210.191.73.183]
role :db,  %w[210.191.73.183]

