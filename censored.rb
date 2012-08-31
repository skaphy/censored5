#!/usr/bin/ruby
# <censored> bot 5.00
# Written by sky

require 'logger'
require 'rubygems'
require 'twitterstream'
require 'json'
require 'twitter'
load "#{File.dirname(File.expand_path(__FILE__))}/init.rb"
require 'tscounter'
require 'database'
require 'spam'
require 'util'
load "words.rb"

STDOUT.sync = true

module Censored
	class Main
	private
		def runQueueThread
			Thread.new do
				running = Tscounter.new
				while true
					poppost = @queue.pop
					# waiting for running processes count is less than MAXPTHREAD
					while running.value > MAXPTHREAD; end
					running.add
					Thread.new(poppost) do |post|
						pid = nil
						begin
							timeout(TIMEOUT_PROCPOST) do
								IO.popen("ruby procpost.rb", "r+") do |pr|
									pid = pr.pid
									parm = {
										"friends" => @friends,
										"post" =>post
									}
									pr.puts parm.to_json
								end
							end
						rescue TimeoutError
							Process.kill(:KILL, pid) if pid
						end
						running.sub
					end
				end
			end
		end
		def runSearchThread
			def getIds(word)
				ids = []
				posts = @twit.search(:q => word, :rpp => SEARCH_NUM)
				posts.each do |post|
					if post["retweeted_status"]
						post = post["retweeted_status"]
					end
					ids.push(post["user"]["id"])
				end
				return ids
			end
			Thread.new do
				while true
					sword = Util.randArray(WORDS)
					sword = [sword[0][0], sword[1][0]]
					ids = [
						getIds(sword[0]),
						getIds(sword[1])
					]
					(ids[0]&ids[1]).each do |id|
						@db.addPoint(id, 3)
					end
					sleep SEARCH_INTERVAL
				end
			end
		end
		def runFollowThread
			Thread.new do
				users = @db.getPointOverUsers(FOLLOW_POINT)
				users.each do |i|
					if !isContained?(i, @friends)
						if !SPAMChecker.isSpamAccount?(i)
							@twit.friend(:add, i)
							@friends.push(i)
							@log.info "id:#{i} is followed now."
						else
							@log.info "id:#{i} may be spam account."
						end
					else
						@log.info "id:#{i} was followed."
					end
				end
			end
		end
		def isContained?(target, array)
			flag = false
			array.each do |i|
				if target == i
					flag = true
					break
				end
			end
			return flag
		end
	public
		def initialize
			# For logging
			@log = Logger.new("log/censored.log")

			# For streaming API
			@stream = TwitterStream.new({
				:consumer_token => CONSUMER_KEY,
				:consumer_secret => CONSUMER_SECRET,
				:access_token => ACCESS_TOKEN,
				:access_secret => ACCESS_TOKEN_SECRET,
			})

			# For search and follow
			Twitter::Client.configure do |conf|
				conf.oauth_consumer_token = CONSUMER_KEY
				conf.oauth_consumer_secret = CONSUMER_SECRET
			end
			@twit = Twitter::Client.new(
				:oauth_access => {
					:key => ACCESS_TOKEN,
					:secret => ACCESS_TOKEN_SECRET
				}
			)

			# For follow
			@db = Database.new

			# init variables
			@friends = []
			@queue = Queue.new

			# run threads
			runQueueThread
			runSearchThread

			@log.info "censored.rb was initialized."
		end
		def run
			begin
				timeout(RECONNECT_TIMEOUT) do
					main
				end
			rescue TimeoutError
				main	# reconnect
			end
		end
		def main
			@stream.userstreams do |post|
				if post["friends"]
					# Receive in the first connection
					@friends = post["friends"]
					@log.info "Received friends list"
					# follow users after recieved friends
					runFollowThread
				else
					# Other messages processing by procpost.rb in different process
					@queue.push(post)
				end
			end
		end
	end
end

if __FILE__ == $0
	(Censored::Main.new).run
end

