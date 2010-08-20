require File.dirname(__FILE__) + '/../lib/stalker'
require 'contest'
require 'mocha'

module Stalker
	def log(msg); end
	def log_error(msg); end
end

class StalkerTest < Test::Unit::TestCase
	setup do
		Stalker.clear!
		$result = -1
		$handled = false
	end

	test "enqueue and work a job" do
		val = rand(999999)
		Stalker.job('my.job') { |args| $result = args['val'] }
		Stalker.enqueue('my.job', :val => val)
		Stalker.prep
		Stalker.work_one_job
		assert_equal val, $result
	end

	test "invoke error handler when defined" do
		Stalker.error { |e| $handled = true }
		Stalker.job('my.job') { fail }
		Stalker.enqueue('my.job')
		Stalker.prep
		Stalker.work_one_job
		assert_equal true, $handled
	end

	test "continue working when error handler not defined" do
		Stalker.job('my.job') { fail }
		Stalker.enqueue('my.job')
		Stalker.prep
		Stalker.work_one_job
		assert_equal false, $handled

	test "access beanstalk job object" do
		Stalker.job('my.job') { |args| assert_equal Beanstalk::Job, args['job'].class }
		Stalker.enqueue('my.job')
		Stalker.prep
		Stalker.work_one_job
	end
end
