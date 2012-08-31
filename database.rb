#!/usr/bin/ruby
# <censored> bot 5.00
# Written by sky
# database.rb - Database module

require 'logger'
require 'rubygems'
require 'mysql'
load "#{File.dirname(File.expand_path(__FILE__))}/init.rb"

module Censored
	class Database
		def initialize
			@db = Mysql.new(DB_HOST, DB_USER, DB_PASS, DB_DATABASE)
			@log = Logger.new("log/database.log")
		end
		def close
			@db.close
		end
		def query(sql)
			@log.debug sql
			@db.query(sql) if !DEBUGMODE
		end
		def updateUser(id, screen_name=nil, name=nil)
			id = id.to_i
			screen_name = @db.quote(screen_name) if screen_name
			name = @db.quote(name) if name
			ret = @db.query("select * from user where id='#{id}'")
			sql = ""
			if ret.num_rows == 0
				# not exist user
				screen_name = "" if !screen_name
				name = "" if !name
				sql = "insert into user (id, screen_name, name, post, point) value ('#{id}', '#{screen_name}', '#{name}', 0, 0)"
			else
				# exist user
				sql = "update user set "
				sql += "screen_name = '#{screen_name}'" if screen_name
				sql += "," if screen_name != nil && name != nil
				sql += " name = '#{name}' " if name
				sql += " where id='#{id}'"
			end
			query(sql)
			ret.free
		end
		def incPostValue(userid)
			userid = userid.to_i
			sql = "update user set post = post + 1 where id='#{userid}'"
			query(sql)
		end
		def addPost(statusid, userid, text)
			statusid = statusid.to_i
			userid = userid.to_i
			sql = "insert into post (id, userid, text) values ('#{statusid}', '#{userid}', '#{@db.quote(text)}')"
			query(sql)
		end
		def addPoint(userid, addpoint)
			addpoint = addpoint.to_i
			sql = "update user set point = point + #{addpoint} where id='#{userid}'"
			query(sql)
		end
		def clearCount
			sql = "update user set point = 0"
			query(sql)
		end
		def getPointOverUsers(point)
			point = point.to_i
			sql = "select id from user where point>#{point}"
			res = query(sql)
			return [] if DEBUGMODE
			ret = []
			res.each do |i|
				ret.push(i[0])
			end
			return ret
		end
		def getUserId(screen_name)
			sql = "select id from user where screen_name='#{@db.quote(screen_name)}'"
			res = query(sql)
			ret = 0
			return 0 if DEBUGMODE
			return 0 if res.num_rows == 0
			ret = res.fetch_row[0].to_i
			res.free
			return ret
		end
	end
end

