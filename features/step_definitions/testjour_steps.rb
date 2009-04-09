require "systemu"
require "fileutils"

Given /^Testjour is configured to run on localhost in a (\w+) directory$/ do |dir_name|
  @args ||= []
  full_path = File.expand_path("./tmp/#{dir_name}")
  @args << "--on=testjour://localhost#{full_path}"
  
  FileUtils.rm_rf full_path
  FileUtils.mkdir_p full_path
end

When /^I run `testjour (.+)`$/ do |args|
  @args ||= []
  @args += args.split
  
  Dir.chdir(@full_dir) do
    testjour_path = File.expand_path(File.dirname(__FILE__) + "/../../../../bin/testjour")
    cmd = "#{testjour_path} #{@args.join(" ")}"
    # puts cmd
    status, @stdout, @stderr = systemu(cmd)
    @exit_code = status.exitstatus
  end
end

Then "it should not print to stderr" do
  @stderr.should == ""
end

Then /^it should (pass|fail) with "(.+)"$/ do |pass_or_fail, text|
  if pass_or_fail == "pass"
    @exit_code.should == 0
  else
    @exit_code.should_not == 0
  end

  @stdout.should include(text)
end

Then /^it should (pass|fail) with$/ do |pass_or_fail, text|
  if pass_or_fail == "pass"
    @exit_code.should == 0
  else
    @exit_code.should_not == 0
  end

  @stdout.should include(text)
end

Then /^the output should contain "(.+)"$/ do |text|
  @stdout.should include(text)
end

Then /^([a-z\.]+) should include "(.+)"$/ do |filename, text|
  Dir.chdir(@full_dir) do
    IO.read(filename).should include(text)
  end
end

Then /^it should run on (\d+) slaves?$/ do |count|
  Dir.chdir(@full_dir) do
    log = IO.read("testjour.log")
    pids = log.scan(/\[\d+\]/).uniq
    
    # One master process and the slaves
    pids.size.should == count.to_i + 1
  end
end

Then /^it should run on 2 remote slaves$/ do
  pids = @stdout.scan(/\[\d+\] ran \d+ steps/).uniq
  pids.size.should == 2
end
