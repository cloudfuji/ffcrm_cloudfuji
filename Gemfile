source "http://rubygems.org"

gem 'bundler_local_development', :group => :development, :require => false
begin
  require 'bundler_local_development'
rescue LoadError
end

gem 'fat_free_crm', :git => 'git://github.com/fatfreecrm/fat_free_crm.git'

group :test, :development do
  gem 'pg'  # Default database for testing
  gem 'combustion'
end

group :test do
  gem 'rspec'
  unless ENV["CI"]
    gem 'ruby-debug',   :platform => :mri_18
    gem (RUBY_VERSION == "1.9.2" ? 'ruby-debug19' : 'debugger'), :platform => :mri_19
  end
end

