require "testjour/commands/command"
require "cucumber"
require "uri"
require "daemons/daemonize"
require "testjour/cucumber_extensions/http_formatter"
require "testjour/mysql"
require "stringio"

module Testjour
module Commands

  class RunSlave < Command

    def execute
      configuration.parse!
      configuration.parse_uri!

      Dir.chdir(configuration.path) do
        Testjour.setup_logger(configuration.path)
        Testjour.logger.info "Starting run:slave"
        begin
          configuration.setup
          configuration.setup_mysql
          require_files
          work
        rescue Object => ex
          Testjour.logger.error "run:slave error: #{ex.message}"
          Testjour.logger.error ex.backtrace.join("\n")
        end
      end
    end

    def work
      queue = RedisQueue.new
      feature_file = true

      while feature_file
        begin
          feature_file = queue.pop(:feature_files)
        rescue Curl::Err::ConnectionFailedError
          feature_file = false
        end

        if feature_file
          Testjour.logger.info "Running: #{feature_file}"
          features = load_plain_text_features(feature_file)
          Testjour.logger.info "Loaded: #{feature_file}"
          execute_features(features)
          Testjour.logger.info "Finished running: #{feature_file}"
        else
          Testjour.logger.info "No feature file found. Finished"
        end
      end
    end

    def execute_features(features)
      visitor = Testjour::HttpFormatter.new(step_mother)
      visitor.options = configuration.cucumber_configuration.options
      Testjour.logger.info "Visiting..."
      visitor.visit_features(features)
    end

    def require_files
      step_mother.load_code_files(configuration.cucumber_configuration.support_to_load)
      step_mother.after_configuration(configuration.cucumber_configuration)
      step_mother.load_code_files(configuration.cucumber_configuration.step_defs_to_load)
    end

  end

end
end