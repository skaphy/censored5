#!/usr/bin/ruby
# <censored> bot 5.00
# Written by sky

require 'logger'
load "#{File.dirname(File.expand_path(__FILE__))}/init.rb"
require 'database'

module Censored
	class ClearCount
		def initialize
			@db = Database.new
		end
		def run
			@db.clearCount
		end
	end
end

if __FILE__ == $0
	(Censored::ClearCount.new).run
end

