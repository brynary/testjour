module Testjour
  
  class FeatureFileFinder
    attr_reader :feature_files
    
    def initialize
      @feature_files = []
    end
    
    def before_feature(feature)
      @current_feature = feature
    end
    
    def before_step(step)
      @feature_files << @current_feature.file
      @feature_files.uniq!
    end
  end

end