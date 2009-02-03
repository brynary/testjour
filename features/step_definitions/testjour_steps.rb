require "systemu"

When /^I run `(.+)`$/ do |args|
  @full_dir = File.expand_path(File.dirname(__FILE__) + "/../../spec/fixtures")
  
  args = args.split[1..-1]
  
  Dir.chdir(@full_dir) do
    @start_time = Time.now
    
    testjour_path = File.expand_path(File.dirname(__FILE__) + "/../../../../bin/testjour")
    status, @stdout, @stderr = systemu "#{testjour_path} #{args.join(' ')}"
    # require "rubygems"; require "ruby-debug"; Debugger.start; debugger
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
  
  @stdout.should be_like(text)
end

Then /^it should (pass|fail) with$/ do |pass_or_fail, text|
  if pass_or_fail == "pass"
    @exit_code.should == 0
  else
    @exit_code.should_not == 0
  end
  
  @stdout.should be_like(text)
end

Then /^(.+) should contain "(.+)"$/ do |filename, text|
  Dir.chdir(@full_dir) do
    IO.read(filename).should be_like(text)
  end
end

Then /^it should run in less than (\d+) seconds?$/ do |seconds|
  @run_time.should < seconds.to_f
end
