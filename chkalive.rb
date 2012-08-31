#!/usr/bin/ruby
# <censored> bot 5.00
# Written by sky
# chkalive.rb - Checking to alive the censored.rb process

require 'logger'
load "#{File.dirname(File.expand_path(__FILE__))}/init.rb"

def exec
	IO.popen("ruby censored.rb") do |io|
		Process.waitpid(io.pid)
	end
end

log = Logger.new("log/chkalive.log")

log.info "chkalive.rb was started."
while true
	exec
	log.error "censored.rb was terminated. Auto reboot."
end

