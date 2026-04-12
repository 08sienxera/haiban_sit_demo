require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

#ENV.update YAML.load_file('public/system/env.yml')[Rails.env] rescue {}

module HaibanSitDemo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Tokyo"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.available_locales = [:ja]
    # ��L�̑Ή�����ȊO�̌��ꂪ�w�肳�ꂽ�ꍇ�A�G���[�Ƃ��邩�̐ݒ�
    config.i18n.enforce_available_locales = true
    config.i18n.default_locale = :ja
    config.active_record.default_timezone = :local

    # ���O��1�����ƂɃ��[�e�[�V����
	config.logger = Logger.new("log/#{Rails.env}.log", 'daily')

    # apache���Ɨv����
    config.action_dispatch.default_headers.delete('X-XSS-Protection')
	#    config.action_dispatch.default_headers.delete('X-Frame-Options')
	#    config.action_dispatch.default_headers.delete('X-Content-Type-Options')

  end
end
