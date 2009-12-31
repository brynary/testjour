require "systemu"
require "fileutils"

Given /^Testjour is configured to run on localhost in a (\w+) directory$/ do |dir_name|
  @args ||= []
  full_path = File.expand_path("./tmp/#{dir_name}")
  @args << "--on=testjour://localhost#{full_path}"
  
  FileUtils.rm_rf full_path
  FileUtils.mkdir_p full_path
end

Given /^Testjour is configured to run on this machine in a (\w+) directory$/ do |dir_name|
  @args ||= []
  full_path = File.expand_path("./tmp/#{dir_name}")
  @args << "--on=testjour://#{Socket.gethostname}#{full_path}"
  
  FileUtils.rm_rf full_path
  FileUtils.mkdir_p full_path
end

Given /^Testjour is configured to use this machine as the queue host$/ do
  @args ||= []
  @args << "--queue-host=#{Socket.gethostname}"
end

Given /^Testjour is configured to use this machine as the rsync host$/ do
  @args ||= []
  @args << "--rsync-uri=#{Socket.gethostname}:/tmp/testjour_feature_run"
end

Given /^a file testjour_preload.rb at the root of the project that logs "Hello, world"$/ do
  File.open(File.join(@full_dir, 'testjour_preload.rb'), 'w') do |file|
    file.puts "Testjour.logger.info 'Hello, world'"
  end
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
    # puts @stderr.to_s
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

Then /^it should pass with no output$/ do
  @exit_code.should == 0
  @stdout.should == ""
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
    if pids.size != count.to_i + 1
      raise("Expected #{count} slave PIDs, got #{pids.size - 1}:\nLog is:\n#{log}")
    end
  end
end

Then /^it should run on 2 remote slaves$/ do
  pids = @stdout.scan(/\[\d+\] ran \d+ steps/).uniq
  pids.size.should == 2
end
