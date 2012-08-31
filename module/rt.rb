#!/usr/bin/ruby
# <censored> bot 5.00
# Written by sky
# module/rt.rb - Splitting unofficial Retweet

module Censored

	class RTPost

		RT_REGEXP = /( ?(?:RT|QT) ?@(?:\w+)[ :] ?(?:.+))/m 

		def initialize
		end

		def self.has_rt?(text)
			return text =~ RT_REGEXP
		end

		def self.split(text, sname=nil)
			ret = []
			if has_rt?(text)
				tmp = text.split(/ ?(?:RT|QT) ?@(\w+)[ :] ?/)
				ret.push([sname, tmp.shift])
				while tmp.length != 0
					ret.push([tmp.shift, tmp.shift])
				end
			else
				ret = [[sname, text]]
			end
			return ret
		end

	end

end

