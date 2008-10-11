module Testjour
  module CLI

    class BaseCommand
      attr_reader :non_options, :options

      def self.command
        self.name.downcase
      end
  
      def self.aliases
        []
      end
  
      def self.help
        nil
      end
  
      def self.detailed_help
        nil
      end
      
      def self.command_and_aliases
        if aliases.any?
          "#{command} (#{aliases.join(", ")})"
        else
          "#{command}"
        end
      end
      
      # def self.usage
      #   message = []
      #   
      #   if help.nil?
      #     message << command_and_aliases
      #   else
      #     message << "#{command_and_aliases}: #{help}"
      #   end
      #   message << detailed_help unless detailed_help.nil?
      #   message << ""
      #   message << "Valid options:"
      #   message
      #   @option_parser.summarize(message)
      # end
        
      def initialize(non_options, options)
        @non_options, @options = non_options, options
      end
    end
    
  end
end