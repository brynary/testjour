require "optparse"

module Testjour
  module CLI

    class BaseCommand
      attr_reader :non_options, :options

      def self.command
        self.name.downcase
      end
      
      def self.inherited(command_class)
        Parser.register_command command_class
      end
      
      def self.options
        {}
      end
  
      def self.help
        nil
      end
  
      def self.detailed_help
        nil
      end
      
      # def self.usage
      #   message = []
      #   
      #   if help.nil?
      #     message << command
      #   else
      #     message << "#{command}: #{help}"
      #   end
      #   message << detailed_help unless detailed_help.nil?
      #   message << ""
      #   message << "Valid options:"
      #   message
      #   @option_parser.summarize(message)
      # end
        
      def initialize(parser, args)
        @parser   = parser
        @options  = {}
        @non_options = option_parser.parse(args)
      end
      
      def option_parser
        OptionParser.new
      end
      
    end
    
  end
end