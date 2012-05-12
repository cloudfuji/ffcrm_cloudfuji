require 'rubygems'
require 'bundler'
require 'rails/all'

Bundler.require :default, :development

require 'rspec/rails'
require 'factory_girl'
require 'ffaker'

# Load factories from fat_free_crm
ffcrm_spec = Gem::Specification.find_by_name("fat_free_crm")
Dir[ffcrm_spec.gem_dir + "/spec/factories/*.rb"].each {|factory| require factory }

Combustion.initialize!

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end

# Cloudfuji::Platform.on_cloudfuji? is false,
# so we need to enable it manually
FatFreeCRM::Cloudfuji.enable_cloudfuji!