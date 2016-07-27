#!/usr/bin/env rspec -cfd

require_relative '../../helpers'

require 'strelka'
require 'mongrel2/testing'
require 'strelka/testing'

require 'strelka/httprequest/cors'


describe Strelka::HTTPRequest::CORS do

	before( :all ) do
		@request_factory = Mongrel2::RequestFactory.new(
			host: 'telomere.com',
			port: '80',
			route: '/api/v1'
		)
	end


	let( :get_request ) do
		req = @request_factory.get( '/api/v1/test' )
		req.extend( described_class )
		req
	end


	describe "header accessors" do

		it "adds a convenience method for accessing the Origin header" do
			expect {
				get_request.header[ :origin ] = 'http://acme.com/api/v1/test'
			}.to change { get_request.origin }.to( URI('http://acme.com/api/v1/test') )
		end

	end


	describe "predicates" do

		let( :options_request ) do
			req = @request_factory.options( '/api/v1/test' )
			req.extend( described_class )
		end


		it "knows when it's a cross-origin request" do
			get_request.headers.merge!( origin: 'http://acme.com/' )
			expect( get_request ).to be_cross_origin
		end


		it "knows it's not a cross-origin request when its Origin matches its Host" do
			get_request.headers.merge!( host: 'acme.com', origin: 'http://acme.com/' )
			expect( get_request ).to_not be_cross_origin
		end


		it "knows when it's a preflight request" do
			options_request.header.host = 'telomere.com'
			options_request.header.origin = 'http://acme.com/'
			options_request.header.access_control_request_method = 'POST'

			expect( options_request ).to be_preflight
		end


		it "knows it's not a preflight request when it doesn't have an Access-Control-Request-Method header" do
			options_request.header.host = 'telomere.com'
			options_request.header.origin = 'http://acme.com/'
			options_request.header.access_control_request_method = nil

			expect( options_request ).to_not be_preflight
		end


		it "knows it's not a preflight request when its verb isn't OPTIONS" do
			get_request.header.host = 'telomere.com'
			get_request.header.origin = 'http://acme.com/'
			get_request.header.access_control_request_method = 'POST'

			expect( get_request ).to_not be_preflight
		end


	end

end

