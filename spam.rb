#!/usr/bin/ruby
# <censored> bot 5.00
# Written by sky

require 'logger'
load "#{File.dirname(File.expand_path(__FILE__))}/init.rb"
require 'twitter'

module Censored
	class SPAMChecker
		def self.isSpamAccount?(id)
			return false
		end
	end
end

