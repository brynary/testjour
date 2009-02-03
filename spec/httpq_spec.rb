require File.dirname(__FILE__) + "/spec_helper"

describe "httpq" do
  before :all do
    start_queue
  end
  
  before :each do
    get "/reset"
  end
  
  it "is empty by default (returns 404)" do
    get "/feature_files"
    response.code.to_i.should == 404
  end
  
  it "can be reset" do
    post "/feature_files", "data" => "features/test.feature"
    get "/reset"
    response.code.to_i.should == 200
    get "/feature_files"
    response.code.to_i.should == 404
  end
  
  it "raises errors for unknown GETs" do
    get "/unknown"
    response.code.to_i.should == 500
  end
  
  it "accepts work" do
    post "/feature_files", "data" => "features/test.feature"
    response.code.to_i.should == 200
  end
  
  it "returns work from the queue" do
    post "/feature_files", "data" => "features/test.feature"
    get "/feature_files"
    response.code.to_i.should == 200
    response.body.should == "features/test.feature"
  end
  
  it "is empty after all work is returned" do
    post "/feature_files", "data" => "features/test.feature"
    get "/feature_files"
    get "/feature_files"
    response.code.to_i.should == 404
  end
  
  it "raises errors for unknown POSTs" do
    post "/unknown"
    response.code.to_i.should == 500
  end
  
  after :all do
    shutdown_queue
  end
end