source 'https://rubygems.org'

gem 'omniauth-shibboleth'
gem 'omniauth-rails_csrf_protection'
gem 'activerecord-import'
gem 'activerecord-session_store'
gem 'acts_as_list'
gem 'addressable'
gem 'autoprefixer-rails', '7.2.2'
gem 'axlsx', git: 'https://github.com/randym/axlsx.git', ref: '776037c0fc799bb09da8c9ea47980bd3bf296874'
gem 'axlsx_rails'
gem 'bootstrap-sass'
gem 'sassc-rails', '>= 2.1.0'
gem 'bootstrap-select-rails'
gem 'bootstrap-toggle-rails'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.37'
gem 'coffee-rails'
gem 'daemons'
gem 'delayed_job_active_record'
gem 'devise'
gem 'dotenv-rails'
gem 'rails-erd'
gem 'faye'
gem 'gon'
gem 'grape', '~> 1.2.5'
gem 'haml-rails'
gem 'hashie-forbidden_attributes'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.9'
gem 'letter_opener'
gem 'momentjs-rails', '>= 2.9.0'
gem 'mysql2', '0.5.2'
gem 'net-ldap'
gem 'omniauth'
gem 'paperclip', '~> 6.1'
gem 'paper_trail', '~> 10.3.1'
gem 'paranoia', '~> 2.4'
gem 'progress_bar'
gem 'puma'
gem 'rails', '5.2.3'
gem 'remotipart'
gem 'rest-client'
gem 'rubyzip', '>= 1.2.1'
gem 'sass-rails'
gem 'sdoc', '~> 1.0.0', group: :doc
gem 'sprockets-rails'
gem 'execjs'
gem 'slack-notifier', '~> 2.3'
gem 'thin'
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'
gem 'underscore-rails', '~> 1.8.3'
gem 'whenever', '~> 1.0.0'
gem 'will_paginate'
gem 'yajl-ruby', require: 'yajl'
gem 'dalli'
gem 'rails_12factor', group: :production
group :deploy do
  gem 'capistrano', '~> 3.11'
  gem 'capistrano-rvm'
  gem 'capistrano-rails', '~> 1.4'
  gem 'capistrano-passenger'
  gem 'capistrano3-delayed-job', '~> 1.7'
end


group :development, :test, :testing do
  gem "factory_bot_rails"
  gem 'faker', '~> 2.8.1'
  gem 'pry'
  gem 'byebug'
end

group :development do
  gem 'foreman'
  gem 'rack-mini-profiler', require: false
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'simplecov', :require => false, :group => :testend
end

group :test do
  gem 'capybara'
  gem 'climate_control'
  gem 'database_cleaner'
  gem 'geckodriver-helper'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec-activejob', '~> 0.6.1'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'selenium-webdriver'
  gem 'shoulda-callback-matchers'
  gem 'shoulda-matchers', "~> 4.1.2", require: false
  gem 'timecop'
  gem 'webmock', '~> 3.7.6'
  gem 'vcr', '~> 5.0.0'
end

group :assets do
  # We don't require this because we only have it so
  # that we can run asset precompile during build without
  # connecting to a database
  # If we allow it to be required though it will screw up
  # schema load / migrations because monkey patching.
  # So what we do is not require it and then generate the
  # require statement in the database.yml that we generate
  # in the hab package build
  gem "activerecord-nulldb-adapter", require: false
end

gem 'eye', :group  => [:production, :development]
