# -*- ruby -*-
# vim: set nosta noet ts=4 sw=4:
# encoding: utf-8

require 'strelka/app' unless defined?( Strelka::App )
require 'strelka/httprequest/cors'
require 'strelka/httpresponse/cors'


# Strelka::App plugin module for Cross-Origin Resource Sharing (CORS)
#
#     class MyService < Strelka::App
#         plugins :cors
#
#         allow_origins '*'
#
#     end # MyService
#
# Resources:
#
# * http://www.w3.org/TR/cors/
# * http://enable-cors.org/server.html
# * http://www.html5rocks.com/en/tutorials/cors/
#
module Strelka::App::CORS
	extend Strelka::Plugin

	run_outside :routing, :restresources
	run_inside  :errors, :sessions, :auth


	# Class methods to add to including applications
	module ClassMethods

		### Extension hook. Add instance variables to extended classes.
		def self::extended( mod )
			mod.instance_variable_set( :@access_controls, [] )
		end


		##
		# An Array of access control tuples of the form:
		#   [ <uri_pattern>, <options_hash> ]
		attr_reader :access_controls


		### Get/declare the origins which are allowed to fetch resources
		def access_control( uri_pattern=nil, **options, &block )
			options[ :block ] = block if block
			self.access_controls << [ uri_pattern, options ]
		end
		alias_method :cors_access_control, :access_control

	end # module ClassMethods


	### Extension callback -- extend the HTTPRequest class with Auth
	### support when this plugin is loaded.
	def self::included( object )
		self.log.debug "Extending Request with CORS mixin"
		Strelka::HTTPRequest.class_eval { include Strelka::HTTPRequest::CORS }
		Strelka::HTTPResponse.class_eval { include Strelka::HTTPResponse::CORS }
		super
	end


	### Extend handled requests with CORS stuff.
	def handle_request( request )
		if request.origin
			self.log.info "Request has an Origin (%p): applying CORS" % [ request.origin ]
			response = if request.is_preflight?
					self.log.debug "Preflight request for %s" % [ request.uri ]
					self.handle_preflight_request( request )
				else
					self.add_response_headers( request )
					super
				end

			return response
		else
			super
		end
	end


	### Add CORS headers to the +response+.
	def add_response_headers( request )
		response = request.response
		response.add_cors_headers
	end


end # module Strelka::App::CORS


