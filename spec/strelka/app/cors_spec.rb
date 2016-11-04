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
		@request_factory = Mongrel2::RequestFactory.new(
			host: 'acme.com',
			port: 80,
			route: '/api/v1',
			headers: {
				origin: 'https://acme.com/'
			}
		)
	end


	it_should_behave_like( "A Strelka Plugin" )


	it "adds a method to applications to declare access control rules" do
		app = Class.new( Strelka::App ) do
			plugins :cors
		end

		expect( app ).to respond_to( :access_controls )
		expect( app ).to respond_to( :cors_access_control )
	end


	it "adds the CORS mixin to the request class" do
		app = Class.new( Strelka::App ) do
			plugins :cors
		end
		app.install_plugins

		response = @request_factory.get( '/api/v1/verify' )

		expect( response ).to respond_to( :cross_origin? )
	end


	it "adds the CORS mixin to the response class" do
		app = Class.new( Strelka::App ) do
			plugins :cors
		end
		app.install_plugins

		response = @request_factory.get( '/api/v1/verify' ).response

		expect( response ).to respond_to( :credentials_allowed? )
	end


	describe "in an app" do

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


		context "handling a regular request" do

			it "sets a default Access-Control-Allow-Origin header on responses" do
				request = @request_factory.get( '/api/v1/verify' )

				response = appclass.new.handle( request )

				expect( response.headers ).to include( :access_control_allow_origin )
				expect( response.headers.access_control_allow_origin ).to eq( request.origin.to_s )
			end

		end



		context "handles a pre-flight request" do

			it "runs access controls blocks that match the request's path" do
				request = @request_factory.options( '/api/v1/verify',
					 access_control_request_method: 'POST'
				)

				appclass.access_control( '/verify' ) do |req, res|
					res.allow_origin( '*' )
					res.allow_headers( 'Content-Type', 'X-Object-Owner' )
				end
				response = appclass.new.handle( request )

				expect( response.headers ).to include(
					:access_control_allow_origin,
					:access_control_allow_headers
				)
				expect( response.headers.access_control_allow_origin ).to eq( '*' )
				expect( response.headers.access_control_allow_headers ).
					to eq( 'Content-Type X-Object-Owner' )
			end


			it "runs access controls blocks that match the request's path as a Regexp" do
				request = @request_factory.options( '/api/v1/verify',
					 access_control_request_method: 'POST'
				)

				appclass.access_control( %r{\A/(verify|concede|command)} ) do |req, res|
					res.allow_origin( '*' )
					res.allow_headers( 'Content-Type', 'X-Object-Owner' )
				end
				response = appclass.new.handle( request )

				expect( response.headers ).to include(
					:access_control_allow_origin,
					:access_control_allow_headers
				)
				expect( response.headers.access_control_allow_origin ).to eq( '*' )
				expect( response.headers.access_control_allow_headers ).
					to eq( 'Content-Type X-Object-Owner' )
			end


			it "runs access controls blocks that don't specify a path" do
				request = @request_factory.options( '/api/v1/verify',
					 access_control_request_method: 'POST'
				)

				appclass.access_control do |req, res|
					res.allow_origin( 'https://acme.com/' )
					res.allow_methods( :GET, :HEAD, :POST )
				end
				response = appclass.new.handle( request )

				expect( response.headers ).to include(
					:access_control_allow_origin,
					:access_control_allow_methods,
					:vary
				)
				expect( response.headers.access_control_allow_origin ).
					to eq( 'https://acme.com/' )
				expect( response.headers.vary.downcase.split(/\s*,\s*/) ).to include( 'origin' )
				expect( response.headers.access_control_allow_methods ).
					to eq( 'GET HEAD POST' )
			end


			it "doesn't run access controls blocks that don't match the request's path" do
				request = @request_factory.options( '/api/v1/verify',
					 access_control_request_method: 'POST'
				)

				appclass.access_control( 'optimise' ) do |req, res|
					res.allow_origin( '*' )
					res.allow_headers( 'Content-Type', 'X-Object-Owner' )
				end
				response = appclass.new.handle( request )

				expect( response.headers ).to_not include( :access_control_allow_headers )
				expect( response.headers.access_control_allow_origin ).to eq( request.origin.to_s )
			end

		end

	end

end

