source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# ruby '2.5.5'
ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Add diff functionality
# https://github.com/samg/diffy
gem 'diffy', '~> 3.3.0'
# Add fuzzy string match functionality
gem 'jaro_winkler', '~> 1.5.1'
# acts_as_tree or ancestry alternative
# https://github.com/ClosureTree/closure_tree
gem 'closure_tree'
# Bootstrap 3
# https://github.com/twbs/bootstrap-sass
gem 'bootstrap-sass'
gem 'sassc-rails', '>= 2.1.0'
# tags
# https://github.com/mbleigh/acts-as-taggable-on
gem 'acts-as-taggable-on', '~> 6.0'
# fingerprinting
# https://github.com/Valve/fingerprintjs-rails
# gem 'fingerprintjs-rails'
gem 'fingerprintjs2-rails', git:'https://github.com/mh61503891/fingerprintjs2-rails.git'
# voting
# https://github.com/bouchard/thumbs_up
gem 'thumbs_up'
# https://github.com/activerecord-hackery/ransack
gem 'ransack', github: 'activerecord-hackery/ransack'
# gem 'ransack'
# https://github.com/minimagick/minimagick
gem 'mini_magick'
# https://github.com/rmagick/rmagick
# gem 'rmagick'
# https://github.com/csquared/IMGKit
gem 'imgkit'
# https://cloud.google.com/natural-language/docs/basics#sentiment_analysis
# https://cloud.google.com/ruby/?tab=tab4
# https://github.com/googleapis/google-cloud-ruby
# https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-language
gem 'google-cloud-language'
# apparently we need this to deploy to heroku
# https://stackoverflow.com/questions/34171147/rails-couldnt-find-file-jquery-ujs-with-type-application-javascript
gem 'jquery-rails'
# https://chartkick.com/
# gem "chartkick"
# use hashids instead of sequential hashids
# https://github.com/jcypret/hashid-rails
gem "hashid-rails", "~> 1.0"
# https://guides.rubyonrails.org/v5.2.0/active_storage_overview.html
gem "google-cloud-storage", "~> 1.8", require: false
# https://github.com/rubocop-hq/rubocop
gem 'rubocop', '~> 0.76.0', require: false
# https://github.com/madrobby/zaru
# used for sanitising filepaths
gem 'zaru'
# https://github.com/jnunemaker/httparty
gem 'httparty'
# https://github.com/mperham/sidekiq
gem 'sidekiq'
# https://github.com/plataformatec/mail_form
gem 'mail_form'
# https://github.com/bkeepers/dotenv
gem 'dotenv-rails', groups: [:development, :test]

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # https://voormedia.github.io/rails-erd
  gem "rails-erd"
  # https://github.com/presidentbeef/brakeman
  gem 'brakeman'
  # https://github.com/roidrage/lograge
  gem "lograge"
  # https://github.com/sickill/rainbow
  gem "rainbow"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
  gem 'webdrivers'
end

group :production do
  gem 'scout_apm'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
