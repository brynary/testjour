module Testjour
  module CLI

    class NoCommandGiven < StandardError
      def message
        "No command given"
      end
    end

    class UnknownCommand < StandardError
      def initialize(command, parser)
        @command, @parser = command, parser
      end

      def message
        "Unknown command: #{@command.inspect}"
      end
    end

    class Parser
      
      def initialize
        @valid_options    = []
        @received_options = {}
        @commands         = []
        @option_parser    = OptionParser.new
        
        yield self
      end

      def option(name, options={})
        options[:long] = name.to_s.gsub("_", "-") unless options[:long]
        @valid_options << name
        @received_options[name] = nil

        opt_args = []
        opt_args << "-#{options[:short]}" if options.has_key?(:short)
        opt_args << "--#{options[:long] || name}"
        opt_args << "=#{options[:param_name]}" if options.has_key?(:param_name)
        opt_args << options[:message]
        
        case options[:type]
        when :int, :integer
          opt_args << Integer
        when :float
          opt_args << Float
        when nil
          # NOP
        else
          raise ArgumentError, "Option #{name} has a bad :type parameter: #{options[:type].inspect}"
        end

        @option_parser.on(*opt_args.compact) do |value|
          @received_options[name] = value
        end
      end

      def command(klass)
        @commands << klass
      end

      def parse_and_execute(args=ARGV)
        begin
          command, non_options = parse(args)
          execute(command, non_options)
        rescue NoCommandGiven, UnknownCommand
          $stderr.puts "ERROR: #{$!.message}"
          $stderr.puts usage
          exit 1
        end
      end

      def parse(args)
        non_options = @option_parser.parse(args)
        command = non_options.shift
        raise NoCommandGiven unless command
        return command, non_options
      end

      def execute(command, non_options)
        command_klass = find_command_klass(command)
        raise UnknownCommand.new(command, self) unless command_klass
        
        return command_klass.new(self, non_options, @received_options).run
      end
      
      def find_command_klass(command)
        @commands.each do |command_klass|
          aliases = [command_klass.command] + command_klass.aliases
          return command_klass if aliases.include?(command)
        end
        
        return nil
      end

      def usage
        message = []
        message << "usage: testjour <SUBCOMMAND> [OPTIONS] [ARGS...]"
        message << "Type 'testjour help <SUBCOMMAND>' for help on a specific subcommand."
        message << "Type 'testjour version' to get this program's version."
        message << ""
        message << "Available subcommands are:"
        
        @commands.sort_by { |c| c.command }.each do |command_klass|
          message << "  " + command_klass.command_and_aliases
        end
        
        message.map { |line| line.chomp }.join("\n")
      end
    end
    
  end
end