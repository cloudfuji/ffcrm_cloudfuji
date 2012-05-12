source :rubygems

gem 'bundler_local_development', :group => :development, :require => false
begin
  require 'bundler_local_development'
rescue LoadError
end

gemspec

gem 'fat_free_crm', :git => 'git://github.com/fatfreecrm/fat_free_crm.git'
gem 'cloudfuji', :git => 'git://github.com/cloudfuji/cloudfuji_client.git'

group :test, :development do
  gem 'pg'  # Default database for testing
end

group :test do
  gem 'rspec'
  gem 'combustion'
  gem 'factory_girl'
  unless ENV["CI"]
    gem 'ruby-debug',   :platform => :mri_18
    gem (RUBY_VERSION == "1.9.2" ? 'ruby-debug19' : 'debugger'), :platform => :mri_19
  end
end

