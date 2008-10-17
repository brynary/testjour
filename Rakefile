require 'rubygems'
require 'hoe'
require './lib/testjour.rb'

Hoe.new('testjour', Testjour::VERSION) do |p|
  p.developer 'Bryan Helmkamp', 'bryan#brynary.com'.sub('#', '@')
  
  p.summary = 'Distributed test running with autodiscovery via Bonjour (for Cucumber first)'
  
  p.extra_deps = [
    ['systemu', '>=1.2.0'],
    ['dnssd', '>=0.6.0']
  ]
end
