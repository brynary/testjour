require File.dirname(__FILE__) + "/spec_helper"

describe "httpq" do
  before :suite do
    start_queue
  end

  after :suite do
    shutdown_queue
  end
  
  before :each do
    get "/reset"
  end
  
  describe "feature files queue" do
    it "is empty by default (returns 404)" do
      get "/feature_files"
      response.code.to_i.should == 404
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
  end
  
  describe "results queue" do
    it "is empty by default (returns 404)" do
      get "/results"
      response.code.to_i.should == 404
    end
    
    it "accepts work" do
      post "/results", "data" => "1"
      response.code.to_i.should == 200
    end
    
    it "returns work from the queue" do
      post "/results", "data" => "result"
      get "/results"
      response.code.to_i.should == 200
      response.body.should == "result"
    end
    
    it "is empty after all work is returned" do
      post "/results", "data" => "result"
      get "/results"
      get "/results"
      response.code.to_i.should == 404
    end
  end
  
  describe "reset" do
    it "should reset the feature files" do
      post "/feature_files", "data" => "features/test.feature"
      get "/reset"
      response.code.to_i.should == 200
      get "/feature_files"
      response.code.to_i.should == 404
    end
    
    it "should reset the results" do
      post "/results", "data" => "result"
      get "/reset"
      response.code.to_i.should == 200
      get "/results"
      response.code.to_i.should == 404
    end
  end
  
  it "raises errors for unknown GETs" do
    get "/unknown"
    response.code.to_i.should == 500
  end
  
  it "raises errors for unknown POSTs" do
    post "/unknown"
    response.code.to_i.should == 500
  end
end