require "cucumber"
require "cucumber/formatters/ansicolor"

module Testjour
  class Colorer
    extend ::Cucumber::Formatters::ANSIColor
  end
end