When /^I run testjour (.+)$/ do |args|
  full_dir = File.expand_path(File.dirname(__FILE__) + "/../../spec/fixtures")
  
  Dir.chdir(full_dir) do
    @exit_code = Testjour::CLI.execute([args], @stdout = StringIO.new, @stderr = StringIO.new)
  end
end

Then /^it should (pass|fail) with "(.+)"$/ do |pass_or_fail, text|
  if pass_or_fail == "pass"
    @exit_code.should == 0
  else
    @exit_code.should_not == 0
  end
  
  @stdout.string.should be_like(text)
end

Then /^it should (pass|fail) with$/ do |pass_or_fail, text|
  if pass_or_fail == "pass"
    @exit_code.should == 0
  else
    @exit_code.should_not == 0
  end
  
  @stdout.string.should be_like(text)
end
