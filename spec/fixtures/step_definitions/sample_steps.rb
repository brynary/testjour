Given /^passing$/ do
end

Given /^failing$/ do
  raise "FAIL"
end

Given /^undefined$/ do
  pending
end

Given /^sleep$/ do
  sleep 1
end

Given /^table value "([^\"]*)"$/ do |value|
end

Then /^the result "([^\"]*)"$/ do |result|
end

Given /^the values:$/ do |table|
  # table is a Cucumber::Ast::Table
end

Then /^ENV\['TESTJOUR_DB'\] should be set$/ do
  ENV["TESTJOUR_DB"].should_not be_nil
end
