require 'rubygems'
require "rake/gempackagetask"
require "rake/clean"
require './lib/testjour.rb'

spec = Gem::Specification.new do |s|
  s.name         = "testjour"
  s.version      = Testjour::VERSION
  s.author       = "Bryan Helmkamp"
  s.email        = "bryan" + "@" + "brynary.com"
  s.homepage     = "http://github.com/brynary/testjour"
  s.summary      = "Distributed test running with autodiscovery via Bonjour (for Cucumber first)"
  s.description  = s.summary
  s.executables  = "testjour"
  s.files        = %w[History.txt MIT-LICENSE.txt README.rdoc Rakefile] + Dir["bin/*"] + Dir["lib/**/*"] + Dir["vendor/**/*"]
  
  s.add_dependency "systemu", ">=1.2.0"
  s.add_dependency "dnssd", ">=0.6.0"
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

desc 'Show information about the gem.'
task :write_gemspec do
  File.open("testjour.gemspec", 'w') do |f|
    f.write spec.to_ruby
  end
  puts "Generated: testjour.gemspec"
end

CLEAN.include ["pkg", "*.gem", "doc", "ri", "coverage"]

desc 'Install the package as a gem.'
task :install_gem => [:clean, :package] do
  gem = Dir['pkg/*.gem'].first
  sh "sudo gem install --local #{gem}"
end
