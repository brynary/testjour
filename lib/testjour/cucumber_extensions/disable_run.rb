# Trick Cucumber into not runing anything itself
module Cucumber

  def self.disable_run
    def CLI.execute_called?
      true
    end
  end

end