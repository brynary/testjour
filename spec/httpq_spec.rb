require File.dirname(__FILE__) + "/spec_helper"

describe "httpq" do
  before :suite do
    start_queue
  end

  after :suite do
    shutdown_queue
  end
  
  before :each do
    @http_queue = Testjour::HttpQueue::QueueProxy.new
    get "/reset"
  end
  
  describe "feature files queue" do
    it "is empty by default (returns 404)" do
      @http_queue.pop(:feature_files).should == nil
    end
    
    it "accepts work" do
      @http_queue.push(:feature_files, "features/test.feature").should == true
    end

    it "returns work from the queue" do
      @http_queue.push(:feature_files, "features/test.feature")
      @http_queue.pop(:feature_files).should == "features/test.feature"
    end

    it "is empty after all work is returned" do
      @http_queue.push(:feature_files, "features/test.feature")
      @http_queue.pop(:feature_files)
      @http_queue.pop(:feature_files).should be_nil
    end
  end
  
  describe "results queue" do
    it "is empty by default (returns 404)" do
      lambda {
        Timeout.timeout(1) do
          @http_queue.pop(:results)
        end
      }.should raise_error(Timeout::Error)
    end
    
    it "accepts work" do
      @http_queue.push(:results, "1").should == true
    end
    
    it "returns work from the queue" do
      @http_queue.push(:results, "result")
      @http_queue.pop(:results).should == "result"
    end
    
    it "is empty after all work is returned" do
      @http_queue.push(:results, "result")
      @http_queue.pop(:results)

      lambda {
        Timeout.timeout(1) do
          @http_queue.pop(:results)
        end
      }.should raise_error(Timeout::Error)
    end
  end
  
  describe "reset" do
    it "should reset the feature files" do
      @http_queue.push(:feature_files, "features/test.feature")
      get "/reset"
      @response_code.should == 200
      @http_queue.pop(:feature_files).should be_nil
    end
    
    it "should reset the results" do
      @http_queue.push(:results, "result")
      get "/reset"
      @response_code.should == 200
      
      lambda {
        Timeout.timeout(1) do
          @http_queue.pop(:results)
        end
      }.should raise_error(Timeout::Error)
    end
  end
  
  it "raises errors for unknown GETs" do
    get "/unknown"
    @response_code.should == 500
  end
  
  it "raises errors for unknown POSTs" do
    post "/unknown"
    @response_code.should == 500
  end
end