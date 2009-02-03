require 'cucumber/ast/visitor'

module Testjour
  
    class StepCounter < Cucumber::Ast::Visitor
      attr_reader :count
      
      def initialize(step_mother)
        super
        @count = 0
      end
      
      def visit_step(step)
        @count += 1
      end
      
    end

end