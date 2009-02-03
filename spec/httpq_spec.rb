require File.dirname(__FILE__) + "/spec_helper"

describe "httpq" do
  before :all do
    start_queue
  end
  
  before :each do
    get "/reset"
  end
  
  it "is empty by default (returns 404)" do
    get "/"
    response.code.to_i.should == 404
  end
  
  it "can be reset" do
    post "/", "data" => "features/test.feature"
    get "/reset"
    response.code.to_i.should == 200
    get "/"
    response.code.to_i.should == 404
  end
  
  it "raises errors for unknown GETs" do
    get "/unknown"
    response.code.to_i.should == 500
  end
  
  it "accepts work" do
    post "/", "data" => "features/test.feature"
    response.code.to_i.should == 200
  end
  
  it "returns work from the queue" do
    post "/", "data" => "features/test.feature"
    get "/"
    response.code.to_i.should == 200
    response.body.should == "features/test.feature"
  end
  
  it "is empty after all work is returned" do
    post "/", "data" => "features/test.feature"
    get "/"
    get "/"
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