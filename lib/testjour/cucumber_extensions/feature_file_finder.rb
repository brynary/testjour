require 'cucumber/ast/visitor'

module Testjour
  
  class FeatureFileFinder < Cucumber::Ast::Visitor
    attr_reader :feature_files
    
    def initialize(step_mother)
      super
      @feature_files = []
    end
    
    def visit_feature(feature)
      @current_feature = feature
      super
    end
    
    def visit_step(step)
      @feature_files << @current_feature.file
      @feature_files.uniq!
    end
  end

end