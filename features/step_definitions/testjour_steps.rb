When /^I run testjour \-\-version$/ do
  Testjour::CLI.new(["--version"], @stdout = StringIO.new, @stderr = StringIO.new)
end

Then /^it should pass with "testjour 0\.3"$/ do
  @stdout.string.should be_like("testjour 0.3")
end
