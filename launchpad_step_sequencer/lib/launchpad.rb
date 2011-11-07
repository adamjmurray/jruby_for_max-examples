# setup the namespace for this project
module Launchpad
end

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'vendor', 'json_pure')
require 'json'

require 'lib/launchpad/adapter'
require 'lib/launchpad/button_timer'
require 'lib/launchpad/flam_timer'
require 'lib/launchpad/pattern'
require 'lib/launchpad/playback_pattern'
require 'lib/launchpad/track'
require 'lib/launchpad/model'
require 'lib/launchpad/view'
require 'lib/launchpad/controller'