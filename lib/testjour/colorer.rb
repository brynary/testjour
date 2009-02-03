require "cucumber"
require "cucumber/formatter/ansicolor"

module Testjour
  class Colorer
    extend ::Cucumber::Formatter::ANSIColor
  end
end