#!/usr/bin/env rspec -cfd -b

require_relative '../../helpers'

require 'rspec'

require 'strelka'
require 'mongrel2/testing'
require 'strelka/testing'
require 'strelka/behavior/plugin'

require 'strelka/app/cors'


describe Strelka::App::CORS do

	before( :all ) do
		@request_factory = Mongrel2::RequestFactory.new( route: '/api/v1' )
	end


	it_should_behave_like( "A Strelka Plugin" )


	it "adds a method to applications to declare origins that are allowed to access it" do
		app = Class.new( Strelka::App ) do
			plugins :cors
		end

		expect( app ).to respond_to( :allow_origins )
	end


	it "adds the CORS mixin to the request class" do
		app = Class.new( Strelka::App ) do
			plugins :cors
		end
		app.install_plugins

		response = @request_factory.get( '/api/v1/verify' )

		expect( response ).to respond_to( :cross_origin? )
	end


	describe "an app that " do

		let( :appclass ) do
			Class.new( Strelka::App ) do
				plugins :cors

				def initialize( appid='cors-test', sspec=TEST_SEND_SPEC, rspec=TEST_RECV_SPEC )
					super
				end

				def handle_request( req )
					super do
						res = req.response
						res.status = HTTP::OK
						res.content_type = 'text/plain'
						res.puts "Ran successfully."

						res
					end
				end
			end
		end


		it "doesn't do anything by default" do
			request = @request_factory.get( '/api/v1/verify' )

			res = appclass.new.handle( request )

			expect( res.headers ).to_not include( :access_control_allow_origin )
		end


		it "allows declaration of a simple public resource" do
			request = @request_factory.get( '/api/v1/verify' )

			appclass.allow_origins( '*' )
			res = appclass.new.handle( request )

			expect( res.headers ).to include( :access_control_allow_origin )
			expect( res.headers.access_control_allow_origin ).to eq( '*' )
		end


		it "allows declaration of a resource that is only accessable from the same origin" do
			request = @request_factory.get( '/api/v1/verify' )

			appclass.allow_origins( nil )
			res = appclass.new.handle( request )

			expect( res.headers ).to include( :access_control_allow_origin )
			expect( res.headers.access_control_allow_origin ).to eq( 'null' )
		end


	end

end

