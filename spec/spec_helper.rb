require 'rubygems'
require 'spork'
require 'database_cleaner'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.use_transactional_fixtures = false
    config.infer_base_class_for_anonymous_controllers = false
    config.order = "random"

    config.before :each do
     if Capybara.current_driver == :selenium
       DatabaseCleaner.strategy = :truncation
     else
       DatabaseCleaner.strategy = :transaction
     end
     DatabaseCleaner.start
    end

    config.after(:each) do
     DatabaseCleaner.clean
    end

    # Include Factory Girl syntax to simplify calls to factories
    config.include FactoryGirl::Syntax::Methods

    config.include ControllerMacros
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  FactoryGirl.reload
end

# Faker does not support random dates
# https://github.com/stympy/faker/pull/73
# So lets extends Faker
# https://gist.github.com/rjackson/4694263
class Faker::Date
  def self.random
    Date.today-rand(10_000)
  end
end