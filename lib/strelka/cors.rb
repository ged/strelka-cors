# -*- ruby -*-
# vim: set nosta noet ts=4 sw=4:
# encoding: utf-8

require 'strelka' unless defined?( Strelka )
require 'strelka/app' unless defined?( Strelka::App )


# Strelka::App plugin module for Cross-Origin Resource Sharing (CORS)
#
#     class MyService < Strelka::App
#         plugins :cors
#
#         allow_origin 'localhost', '127.0.0.1', 'example.com'
#
#     end # MyService
#
# References:
#
# * http://www.w3.org/TR/cors/
#
module Strelka::App::CORS
	extend Strelka::App::Plugin

	run_before :routing, :restresources
	run_after  :templating, :errors, :sessions, :auth


	### Mark and time the app.
	def handle_request( request )
		Metriks.meter( "#@metriks_key.requests" ).mark

		response = nil
		Metriks.timer( "#@metriks_key.duration.app" ).time do
			response = super
		end

		self.log.debug "Returning response: %p" % [ response ]
		return response
	end

end # module Strelka::App::Metriks


