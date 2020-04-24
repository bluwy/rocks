# frozen_string_literal: true

require 'gosu'
require 'chipmunk'

# Require all ruby files in lib
Dir[File.join(__dir__, 'lib/**/*.rb')].sort.each { |file| puts file }

# game = Game.new
# game.show
