require "systemu"

When /^I run `(.+)`$/ do |args|
  args = args.split[1..-1]
  
  Dir.chdir(@full_dir) do
    @start_time = Time.now
    
    testjour_path = File.expand_path(File.dirname(__FILE__) + "/../../../../bin/testjour")
    status, @stdout, @stderr = systemu "#{testjour_path} #{args.join(' ')}"
    @exit_code = status.exitstatus
    
    @run_time = Time.now - @start_time
  end
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

Then /^it should run in less than (\d+) seconds?$/ do |seconds|
  @run_time.should < seconds.to_f
end
