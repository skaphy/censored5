#!/usr/bin/ruby
# <censored> bot 5.00
# Written by sky
# procpost.rb - Processing posts

require 'logger'
load "#{File.dirname(File.expand_path(__FILE__))}/init.rb"
require 'rubygems'
require 'json'
require 'twitter'
require 'jcode'
require 'database'
require 'module/rt'
load "words.rb"

module Censored
	# For Non Official Retweet
	class Procpost
		def initialize
			@log = Logger.new("log/procpost.log")
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
			@db = Database.new
		end
		def convertString(text)
			return text.tr("Ａ-Ｚ", "A-Z").tr("A-Z", "a-z").tr("ァ-ン", "ぁ-ん")
		end
		# Checking is post contain any <censored> words
		# returns all found words
		# if it cannot find any words, it returns []
		def isCensored?(orgtext)
			found = []
			WORDS.each do |word|
				text = orgtext
				mword = word[0]
				if !word[1]
					# no exact match
					text = convertString(text)
					mword = convertString(mword)
				end
				found.push(word[0]) if text.index(mword)
			end
			return found
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
		def addCountScrName(sn)
			id = @db.getUserId(sn)
			id = @twit.user(sn).id if id == 0
			# What does twitter4r return if user is not found?
			@db.updateUser(id, sn)
			@db.addPoint(id, 1)
		end
		def procForReply(text)
			if text.index(/^\.? ?@\w+/) == 0
				@log.info "reply found"
				# It post is reply.
				users = text.scan(/@(\w+)/)[0]
				@log.info "all reply users: @#{users.join(",@")}"
				users.each do |sn|
					addCountScrName(sn)
				end
			end
		end
		def run
			json = JSON.parse(gets)
			friends = json["friends"]
			post = json["post"]
			if post["text"] && post["user"]["id"] != OWNID &&
			   isContained?(post["user"]["id"], friends)
				if !post["retweeted_status"]
					# Post is not official retweet
					@db.incPostValue(post["user"]["id"])
					sppost = RTPost.split(post["text"], post["user"]["screen_name"])
					if isCensored?(sppost[0][1]).length > 0
						# RT comment or text is censored
						@db.updateUser(post["user"]["id"], post["user"]["screen_name"], post["user"]["name"])
						@log.debug "censored: #{post["user"]["screen_name"]}: #{post["text"]} (#{sppost[0][1]})"
						posttext = "censored: @#{post["user"]["screen_name"]}: #{post["text"].gsub("@", "")}"
						posttext = posttext.split(//)[0,140].to_s
						@db.addPost(post["id"], post["user"]["id"], post["text"])
						@twit.status(:post, posttext) if !DEBUGMODE
					end
					sppost[1, sppost.length-1].each do |p|
						# Text includes unofficial RT
						if isCensored?(p[1]).length > 0
							@log.debug "RT(@#{p[0]}:#{p[1]}): add 1pt"
							addCountScrName(p[0])
						end
					end
					# If this tweet is reply?
					procForReply(post["text"])
				else
					# Post is official retweet
					rtpost = post["retweeted_status"]
					if rtpost["user"]["id"] != OWNID
						@db.updateUser(rtpost["user"]["id"], rtpost["user"]["screen_name"], rtpost["user"]["name"])
						@db.addPoint(rtpost["user"]["id"], 2)
					end
				end
			end
		end
	end
end

if __FILE__ == $0
	(Censored::Procpost.new).run
end

