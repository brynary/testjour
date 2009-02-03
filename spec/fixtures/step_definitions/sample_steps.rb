Given /^passing$/ do
end

Given /^failing$/ do
  raise "FAIL"
end

Given /^wait 1 second$/ do
  sleep 1
end
