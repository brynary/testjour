Given /^passing$/ do
end

Given /^failing$/ do
  raise "FAIL"
end

Given /^undefined$/ do
  pending
end
