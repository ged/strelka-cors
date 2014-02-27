#!/usr/bin/ruby
# coding: utf-8

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent

	srcdir = basedir.parent
	strelkadir = srcdir + 'Strelka'
	strelkalibdir = strelkadir + 'lib'

	$LOAD_PATH.unshift( strelkalibdir.to_s ) unless $LOAD_PATH.include?( strelkalibdir.to_s )
}

# SimpleCov test coverage reporting; enable this using the :coverage rake task
if ENV['COVERAGE']
	$stderr.puts "\n\n>>> Enabling coverage report.\n\n"
	require 'simplecov'
	SimpleCov.start do
		add_filter 'spec'
		add_group "Needing tests" do |file|
			file.covered_percent < 90
		end
	end
end

require 'loggability'
require 'loggability/spechelpers'
require 'configurability'

require 'rspec'
require 'mongrel2'
require 'mongrel2/testing'

require 'strelka'
require 'strelka/testing'


Loggability.format_with( :color ) if $stdout.tty?


### RSpec helper functions.
module Strelka::CORSSpecHelpers

	# Send and receive specs for the test app
	TEST_SEND_SPEC = 'tcp://127.0.0.1:9997'
	TEST_RECV_SPEC = 'tcp://127.0.0.1:9996'

end # Strelka::MetriksSpecHelpers


abort "You need a version of RSpec >= 2.6.0" unless defined?( RSpec )

### Mock with RSpec
RSpec.configure do |config|
	include Strelka::Constants
	include Strelka::CORSSpecHelpers

	config.run_all_when_everything_filtered = true
	config.filter_run :focus
	config.order = 'random'
	config.mock_with( :rspec ) do |mock|
		mock.syntax = :expect
	end

	config.include( Loggability::SpecHelpers )
	config.include( Mongrel2::SpecHelpers )
	config.include( Strelka::Constants )
	config.include( Strelka::Testing )
	config.include( Strelka::CORSSpecHelpers )
end

# vim: set nosta noet ts=4 sw=4:

