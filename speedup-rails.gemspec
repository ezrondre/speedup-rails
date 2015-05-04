$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "speedup/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "speedup-rails"
  s.version     = Speedup::VERSION
  s.authors     = ["Ondřej Ezr"]
  s.email       = ["ezrondre@fit.cvut.cz"]
  s.homepage    = "https://github.com/ezrondre/speedup-rails"
  s.summary     = "SpeedUpRails provide analyzing and motitoring tool for rails."
  s.description = "SpeedUpRails is written in hope it will help develop faster rails applications."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'rails'
  # s.add_dependency 'railties', '>= 3.0.0'

  s.add_dependency 'bullet'
  s.add_dependency 'ruby-prof'
  s.add_dependency 'rack-mini-profiler'
  s.add_dependency 'speedup-adapters'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'

end
