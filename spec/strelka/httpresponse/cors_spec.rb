#!/usr/bin/env rspec -cfd

require_relative '../../helpers'

require 'strelka'
require 'mongrel2/testing'
require 'strelka/testing'

require 'strelka/httprequest/cors'
require 'strelka/httpresponse/cors'


describe Strelka::HTTPResponse::CORS do

	before( :all ) do
		@request_factory = Mongrel2::RequestFactory.new(
			host: 'telomere.com',
			port: '80',
			route: '/api/v1',
			headers: {
				origin: 'https://telomere.com'
			}
		)
	end


	let( :regular_request ) do
		req = @request_factory.get( '/api/v1/test' )
		req.extend( Strelka::HTTPRequest::CORS )
		req.response.extend( described_class )
		req
	end

	let( :regular_response ) do
		regular_request.response
	end


	let( :preflight_request ) do
		req = @request_factory.options( '/api/v1/test', access_control_request_method: 'POST' )
		req.extend( Strelka::HTTPRequest::CORS )
		req.response.extend( described_class )
		req
	end

	let( :preflight_response ) do
		preflight_request.response
	end


	describe "header accessors" do

		it "adds a convenience method for setting allowed origin" do
			regular_response.allow_origin( 'http://acme.com' )

			expect {
				regular_response.add_cors_headers
			}.to change { regular_response.header.access_control_allow_origin }.to( 'http://acme.com' )
		end


		it "adds a convenience method for allowing any origin" do
			regular_response.allow_any_origin

			expect {
				regular_response.add_cors_headers
			}.to change { regular_response.header.access_control_allow_origin }.to( '*' )
		end


		it "sets the `Vary` response header to `Origin` if it specifies an explicit Origin" do
			regular_response.allow_origin( 'http://acme.com' )

			expect {
				regular_response.add_cors_headers
			}.to change { regular_response.header.vary }.to( match(/\borigin\b/i) )
		end


		it "doesn't set the `Vary` response header to `Origin` if it allows any origin" do
			regular_response.allow_any_origin

			expect {
				regular_response.add_cors_headers
			}.to_not change { regular_response.header.vary }
		end


		it "adds `Origin` to an existing Vary header if it specifies an explicit Origin" do
			regular_response.allow_origin( 'http://acme.com' )
			regular_response.header.vary = 'content-encoding, content-type'

			regular_response.add_cors_headers

			expect( regular_response.header.vary.downcase.split(/\s*,\s*/) ).
				to include( 'origin', 'content-encoding', 'content-type' )
		end


		it "adds a convenience method for allowing a single header" do
			preflight_response.allow_header :content_type
			preflight_response.allow_header :x_thingfish_owner

			expect {
				preflight_response.add_cors_headers
			}.to change { preflight_response.header.access_control_allow_headers }
			expect( preflight_response.header.access_control_allow_headers.split ).to include(
				'Content-Type',
				'X-Thingfish-Owner'
			)
		end


		it "adds a convenience method for allowing several headers" do
			preflight_response.allow_headers :content_type, :vary
			preflight_response.allow_headers 'x-ordered-by', 'x-offset', 'x-set-size'

			expect {
				preflight_response.add_cors_headers
			}.to change { preflight_response.header.access_control_allow_headers }
			expect( preflight_response.header.access_control_allow_headers.split ).to include(
				'Content-Type',
				'Vary',
				'X-Ordered-By',
				'X-Offset',
				'X-Set-Size'
			)
		end


		it "adds a convenience method for setting the set of allowed request headers" do
			preflight_response.allowed_headers = ['content-type', 'x-sorted-by']

			expect {
				preflight_response.add_cors_headers
			}.to change { preflight_response.header.access_control_allow_headers }
			expect( preflight_response.header.access_control_allow_headers.split ).to include(
				'Content-Type',
				'X-Sorted-By'
			)
		end


		it "doesn't set exposed headers on a response to a preflight request" do
			preflight_response.expose_headers( :content_type, :content_disposition )
			preflight_response.add_cors_headers

			expect( preflight_response.headers.access_control_exposed_headers ).to be_nil
		end


		it "adds a convenience method for exposing a single header" do
			regular_response.expose_header :content_type
			regular_response.expose_header :x_thingfish_owner

			expect {
				regular_response.add_cors_headers
			}.to change { regular_response.header.access_control_expose_headers }
			expect( regular_response.header.access_control_expose_headers.split ).to include(
				'Content-Type',
				'X-Thingfish-Owner'
			)
		end


		it "adds a convenience method for exposing several of the response headers" do
			regular_response.expose_headers :content_type, :vary
			regular_response.expose_headers 'x-ordered-by', 'x-offset', 'x-set-size'

			expect {
				regular_response.add_cors_headers
			}.to change { regular_response.header.access_control_expose_headers }
			expect( regular_response.header.access_control_expose_headers.split ).to include(
				'Content-Type',
				'Vary',
				'X-Ordered-By',
				'X-Offset',
				'X-Set-Size'
			)
		end


		it "adds a convenience method for setting the set of exposed response headers" do
			regular_response.exposed_headers = ['content-type', 'x-sorted-by']

			expect {
				regular_response.add_cors_headers
			}.to change { regular_response.header.access_control_expose_headers }
			expect( regular_response.header.access_control_expose_headers.split ).to include(
				'Content-Type',
				'X-Sorted-By'
			)
		end


		it "doesn't set allowed headers on a response to a regular request" do
			regular_response.allow_headers( :content_type, :content_disposition )
			regular_response.add_cors_headers

			expect( regular_response.headers.access_control_allow_headers ).to be_nil
		end


		it "adds a convenience method for allowing particular HTTP methods" do
			preflight_response.allow_methods( :GET, :POST, :PATCH )
			preflight_response.add_cors_headers

			expect(
				preflight_response.header.access_control_allow_methods.split
			).to include( 'GET', 'POST', 'PATCH' )
		end


		it "adds a convenience method for allowing cookies (credentials)" do
			preflight_response.allow_credentials
			preflight_response.add_cors_headers

			expect( preflight_response.header.access_control_allow_credentials ).to eq( 'true' )
		end


		it "adds a convenience method for setting the maximum number of seconds a preflight " \
		   "request can be cached" do
			preflight_response.access_control_max_age = 300
			preflight_response.add_cors_headers

			expect( preflight_response.header.access_control_max_age ).to eq( '300' )
		end

	end


end

