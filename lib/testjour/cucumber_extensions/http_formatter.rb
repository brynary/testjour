require 'socket'
require 'english'
require 'cucumber/formatter/console'
require 'testjour/result'

module Testjour
  class Visitor
    attr_accessor :options
    attr_reader :step_mother

    def initialize(step_mother)
      @options = {}
      @step_mother = step_mother
    end

    def matches_scenario_names?(node)
      scenario_names = options[:scenario_names] || []
      scenario_names.empty? || node.matches_scenario_names?(scenario_names)
    end

    def visit_features(features)
      Testjour.logger.info "visit_features..."
      features.accept(self)
      Testjour.logger.info "visit_features done"
    end

    def visit_feature(feature)
      Testjour.logger.info "visit_feature..."
      feature.accept(self)
      Testjour.logger.info "visit_feature done"
    end

    def visit_comment(comment)
      Testjour.logger.info "visit_comment"
      comment.accept(self)
      Testjour.logger.info "visit_comment done"
    end

    def visit_comment_line(comment_line)
    end

    def visit_tags(tags)
      Testjour.logger.info "visit_tags"
      tags.accept(self)
      Testjour.logger.info "visit_tags done"
    end

    def visit_tag_name(tag_name)
    end

    def visit_feature_name(name)
    end

    # +feature_element+ is either Scenario or ScenarioOutline
    def visit_feature_element(feature_element)
      Testjour.logger.info "visit_feature element..."
      feature_element.accept(self)
      Testjour.logger.info "visit_feature element done"
    end

    def visit_background(background)
      Testjour.logger.info "visit_background"
      background.accept(self)
      Testjour.logger.info "visit_background done"
    end

    def visit_background_name(keyword, name, file_colon_line, source_indent)
    end

    def visit_examples(examples)
      Testjour.logger.info "visit_examples"
      examples.accept(self)
      Testjour.logger.info "visit_examples done"
    end

    def visit_examples_name(keyword, name)
    end

    def visit_outline_table(outline_table)
      Testjour.logger.info "visit_outline_table"
      outline_table.accept(self)
      Testjour.logger.info "visit_outline_table done"
    end

    def visit_scenario_name(keyword, name, file_colon_line, source_indent)
    end

    def visit_steps(steps)
      Testjour.logger.info "visit_steps..."
      steps.accept(self)
      Testjour.logger.info "visit_steps done"
    end

    def visit_step(step)
      Testjour.logger.info "visit_step"
      step.accept(self)
      Testjour.logger.info "visit_step done"
    end

    def visit_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
      Testjour.logger.info "visit_step_result"
      visit_step_name(keyword, step_match, status, source_indent, background)
      visit_multiline_arg(multiline_arg) if multiline_arg
      visit_exception(exception, status) if exception
      Testjour.logger.info "visit_step_result done"
    end

    def visit_step_name(keyword, step_match, status, source_indent, background) #:nodoc:
      Testjour.logger.info "visit_step name."
    end

    def visit_multiline_arg(multiline_arg) #:nodoc:
      Testjour.logger.info "visit_multiline_arg"
      multiline_arg.accept(self)
      Testjour.logger.info "visit_multiline_arg done"
    end

    def visit_exception(exception, status) #:nodoc:
    end

    def visit_py_string(string)
    end

    def visit_table_row(table_row)
      Testjour.logger.info "visit_table_row"
      table_row.accept(self)
      Testjour.logger.info "visit_table_row done"
    end

    def visit_table_cell(table_cell)
      Testjour.logger.info "visit_table_cell"
      table_cell.accept(self)
      Testjour.logger.info "visit_table_cell done"
    end

    def visit_table_cell_value(value, width, status)
    end

    def announce(announcement)
    end

  end
  
  class HttpFormatter < ::Testjour::Visitor

    def initialize(step_mother, io, queue_uri)
      super(step_mother)
      @queue_uri = queue_uri
    end
    
    def visit_multiline_arg(multiline_arg)
      @multiline_arg = true
      super
      @multiline_arg = false
    end
    
    def visit_step(step)
      step_start = Time.now
      super

      if step.respond_to?(:status)
        progress(Time.now - step_start, step)
      end
    end

    def visit_table_cell_value(value, width, status)
      if (status != :skipped_param) && !@multiline_arg
        progress(0.0, nil, status)
      end
    end
    
  private

    def progress(time, step_invocation, status = nil)
      HttpQueue.with_queue(@queue_uri) do |queue|
        queue.push(:results, Result.new(time, step_invocation, status))
      end
    end
    
  end

end