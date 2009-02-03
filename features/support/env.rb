require File.expand_path(File.dirname(__FILE__) + "/../../lib/testjour")

require 'spec/expectations'

def be_like(expected)
  simple_matcher "should be like #{expected.inspect}" do |actual|
    actual.strip == expected.strip
  end
end