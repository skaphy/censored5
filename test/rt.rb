#!/usr/bin/ruby
# <censored> bot 5.00
# Written by sky
# test/rt.rb - Unittest for module/rt.rb module

require 'test/unit'
require '../module/rt'

module Censored

	module Test

		class RTTest < ::Test::Unit::TestCase

			NORTTEXT="test"
			NORTTEXT_RES=[
				[nil, "test"]
			]
			RT1TEXT="response text RT @example: original text"
			RT1TEXT_RES=[
				[nil, "response text"],
				["example", "original text"]
			]
			RT2TEXT="response text 2 RT @example2: response text 1 RT @example1: original text"
			RT2TEXT_RES=[
				[nil, "response text 2"],
				["example2", "response text 1"],
				["example1", "original text"]
			]

			def setup
			end

			def test_nort
				assert_equal(RTPost.split(NORTTEXT), NORTTEXT_RES)
			end

			def test_rt1
				assert_equal(RTPost.split(RT1TEXT), RT1TEXT_RES)
			end

			def test_rt2
				assert_equal(RTPost.split(RT2TEXT), RT2TEXT_RES)
			end

			def test_rt2_sn
				res = RT2TEXT_RES
				res[0][0] = "example3"
				assert_equal(RTPost.split(RT2TEXT, "example3"), RT2TEXT_RES)
			end

		end

	end

end

