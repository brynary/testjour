Given /^passing$/ do
end

Given /^failing$/ do
  raise "FAIL"
end

Given /^undefined$/ do
  pending
end

Then /^ENV\['TESTJOUR_DB'\] should be set$/ do
  ENV["TESTJOUR_DB"].should_not be_nil
end
