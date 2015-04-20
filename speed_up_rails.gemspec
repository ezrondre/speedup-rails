$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "speed_up_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "speed_up_rails"
  s.version     = SpeedUpRails::VERSION
  s.authors     = ["Ondřej Ezr"]
  s.email       = ["ezro@fit.cvut.cz"]
  s.homepage    = "https://github.com/phoenixek12/speedup_rails"
  s.summary     = "SpeedUpRails provide analyzing and motitoring tool for rails."
  s.description = "SpeedUpRails is written in hope it will help develop faster rails applications."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.1"

  s.add_dependency 'bullet'
  s.add_dependency 'ruby-prof'
  s.add_dependency 'rack-mini-profiler'
  s.add_dependency 'speed_up_rails_adapters'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'

end
