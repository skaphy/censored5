#!/usr/bin/ruby
# <censored> bot 5.00
# Written by sky
# tscounter.rb - Thread safe counter

require 'thread'

class Tscounter
	attr_reader :value
	def initialize(count=0)
		@value = count.to_i
		@mutex = Mutex.new
	end
	def add(a=1)
		@mutex.synchronize do
			@value += a.to_i
		end
		return self
	end
	def +(a)
		return add(a)
	end
	def sub(d=1)
		return add(-d)
	end
	def -(d)
		return sub(d)
	end
end

