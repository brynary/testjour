When /^I run testjour (.+)$/ do |args|
  @exit_code = Testjour::CLI.execute([args], @stdout = StringIO.new, @stderr = StringIO.new)
end

Then /^it should pass with "(.+)"$/ do |text|
  @exit_code.should == 0
  @stdout.string.should be_like(text)
end

Then /^it should pass with$/ do |text|
  @exit_code.should == 0
  @stdout.string.should be_like(text)
end
