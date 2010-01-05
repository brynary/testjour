require File.expand_path(File.dirname(__FILE__) + "/../../lib/testjour")

require 'spec/expectations'

def be_like(expected)
  simple_matcher "should be like #{expected.inspect}" do |actual|
    actual.strip == expected.strip
  end
end

def testjour_cleanup
  @full_dir = File.expand_path(File.dirname(__FILE__) + "/../../spec/fixtures")
  
  Dir.chdir(@full_dir) do
    File.unlink("testjour.log") if File.exists?("testjour.log")
    File.unlink("testjour_preload.rb") if File.exists?("testjour_preload.rb")
  end
end

Before do
  testjour_cleanup
end

After do
  # testjour_cleanup
end