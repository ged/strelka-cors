# -*- ruby -*-
# vim: set nosta noet ts=4 sw=4:
# encoding: utf-8

require 'strelka' unless defined?( Strelka )
require 'strelka/app' unless defined?( Strelka::App )
require 'strelka/httprequest/cors'


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
			mod.instance_variable_set( :@allowed_origins, [] )
		end


		### Get/declare the origins which are allowed to fetch resources
		def allow_origins( *origins )
			unless origins.empty?
				@allowed_origins.concat( origins )
			end
			return @allowed_origins
		end

	end # module ClassMethods


	### Extension callback -- extend the HTTPRequest class with Auth
	### support when this plugin is loaded.
	def self::included( object )
		self.log.debug "Extending Request with CORS mixin"
		Strelka::HTTPRequest.class_eval { include Strelka::HTTPRequest::CORS }
		super
	end


	### Extend handled requests with CORS stuff.
	def handle_request( request )
		super { request.response }
	end


end # module Strelka::App::CORS


