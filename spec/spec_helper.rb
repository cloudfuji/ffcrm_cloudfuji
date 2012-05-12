require 'rubygems'
require 'bundler'

Bundler.require :default, :development

Combustion.initialize!

require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl'
require 'ffaker'

# Load factories from fat_free_crm
ffcrm_spec = Gem::Specification.find_by_name("fat_free_crm")
Dir[ffcrm_spec.gem_dir + "/spec/factories/*.rb"].each {|factory| require factory }


RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.mock_with :rspec

  config.filter_run :focused => true
  config.run_all_when_everything_filtered = true
  config.alias_example_to :fit, :focused => true
end
