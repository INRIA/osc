#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
require File.expand_path('../boot', __FILE__)

require 'rails/all'


if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module OscNew
  class Application < Rails::Application
    #### Prise en compte des vieux plugin 2.3 style ####
    config.before_configuration do
      $:.unshift File.expand_path("#{__FILE__}/../../old_plugins/authorization/lib")
      require 'authorization'   
      $:.unshift File.expand_path("#{__FILE__}/../../old_plugins/auto_complete/lib")
      require 'auto_complete' 
      $:.unshift File.expand_path("#{__FILE__}/../../old_plugins/file_column/lib")
      require 'file_column'  
      $:.unshift File.expand_path("#{__FILE__}/../../old_plugins/filter/lib")
      require 'filtr'  
      $:.unshift File.expand_path("#{__FILE__}/../../old_plugins/prototype_legacy_helper/lib")
      require 'prototype_legacy_helper' 
      $:.unshift File.expand_path("#{__FILE__}/../../old_plugins/redbox/lib")
      require 'redbox_helper'
      $:.unshift File.expand_path("#{__FILE__}/../../old_plugins/sub_list/lib")
      require 'sub_list_system'  
      $:.unshift File.expand_path("#{__FILE__}/../../old_plugins/unobtrusive_date_picker/lib")
      require 'unobtrusive_date_picker'  
      $:.unshift File.expand_path("#{__FILE__}/../../old_plugins/relative_time_helpers/lib/active_reload")
      require 'relative_time_helpers'  
  end
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.default_locale = :fr
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"
    

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password,:api_key]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.1'

    config.autoload_paths << "#{Rails.root}/lib"
  end
end
