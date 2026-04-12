source "https://rubygems.org"

ruby "3.2.3"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.3", ">= 7.1.3.2"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use mysql as the database for Active Record
gem "mysql2", "~> 0.5"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :test,:development do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem 'rdoc', '~> 6.7'
  gem 'rails-erd' # 追記
  gem 'solargraph' # Ruby補完
  gem 'rufo' 

end

gem 'exception_notification'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'capistrano' ,'3.18.1'
gem 'capistrano-rails', group: :development
gem 'capistrano-bundler'
gem 'capistrano-rvm'
gem 'capistrano3-delayed-job'
gem 'unicorn'
gem 'mail'
gem 'activerecord-session_store'
gem 'will_paginate'
gem 'i18n'
gem 'rubyzip', require: 'zip'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'redis-actionpack'
gem 'font-awesome-sass'

gem 'rmagick'
gem 'writeexcel'
gem "roo", "~> 2.10.0"
gem 'roo-xls'

# gem 'axlsx'
gem 'spreadsheet'
gem 'prawn' ,'2.4.0'
gem 'prawn-table'
gem 'rqrcode'
gem 'rqrcode_png'

gem 'ed25519'
gem 'bcrypt_pbkdf'
gem 'matrix'
gem 'ttfunk','1.7.0'
gem 'color', '~> 1.8'
group :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'rails-controller-testing'
end
gem 'sshkit','1.22.1'
