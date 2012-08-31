#!/usr/bin/ruby
# <censored> bot 5.00
# Written by sky
# util.rb - Utility methods

load "#{File.dirname(File.expand_path(__FILE__))}/init.rb"

module Censored
	module Util
		# randomize array
		def randArray(ary)
			return sort_by{|i|rand}
		end
	end
end

