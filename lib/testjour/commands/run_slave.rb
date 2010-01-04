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

    # Boolean indicating whether this worker can or can not fork.
    # Automatically set if a fork(2) fails.
    attr_accessor :cant_fork

    def execute
      configuration.parse!
      configuration.parse_uri!

      Dir.chdir(dir) do
        Testjour.setup_logger(dir)
        Testjour.logger.info "Starting #{self.class.name}"
        
        before_require
        
        begin
          configuration.setup
          configuration.setup_mysql
          
          require_cucumber_files
          preload_app
          
          work
        rescue Object => ex
          Testjour.logger.error "#{self.class.name} error: #{ex.message}"
          Testjour.logger.error ex.backtrace.join("\n")
        end
      end
    end
    
    def dir
      configuration.path
    end
    
    def before_require
      enable_gc_optimizations
    end

    def work
      queue = RedisQueue.new(configuration.queue_host,
                             configuration.queue_prefix,
                             configuration.queue_timeout)
      feature_file = true

      while feature_file
        if (feature_file = queue.pop(:feature_files))
          Testjour.logger.info "Loading: #{feature_file}"
          features = load_plain_text_features(feature_file)
          parent_pid = $PID
          if @child = fork
            Testjour.logger.info "Forked #{@child} to run #{feature_file}"
            Process.wait
            Testjour.logger.info "Finished running: #{feature_file}"
          else
            Testjour.override_logger_pid(parent_pid)
            Testjour.logger.info "Executing: #{feature_file}"
            execute_features(features)
            exit! unless @cant_fork
          end
        else
          Testjour.logger.info "No feature file found. Finished"
        end
      end
    end

    def execute_features(features)
      http_formatter = Testjour::HttpFormatter.new(configuration)
      tree_walker = Cucumber::Ast::TreeWalker.new(step_mother, [http_formatter])
      tree_walker.options = configuration.cucumber_configuration.options
      Testjour.logger.info "Visiting..."
      tree_walker.visit_features(features)
    end

    def require_cucumber_files
      step_mother.load_code_files(configuration.cucumber_configuration.support_to_load)
      step_mother.after_configuration(configuration.cucumber_configuration)
      step_mother.load_code_files(configuration.cucumber_configuration.step_defs_to_load)
    end
    
    def preload_app
      if File.exist?('./testjour_preload.rb')
        Testjour.logger.info 'Requiring ./testjour_preload.rb'
        require './testjour_preload.rb'
      end
    end
    
    # Not every platform supports fork. Here we do our magic to
    # determine if yours does.
    def fork
      return if @cant_fork

      begin
        Kernel.fork
      rescue NotImplementedError
        @cant_fork = true
        nil
      end
    end
    
    # Enables GC Optimizations if you're running REE.
    # http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
    def enable_gc_optimizations
      if GC.respond_to?(:copy_on_write_friendly=)
        GC.copy_on_write_friendly = true
      end
    end

  end

end
end