# -*- ruby -*-
#encoding: utf-8

require 'strelka/httprequest'


# The mixin that adds methods to Strelka::HTTPRequest for
# Cross-Origin Resource Sharing (CORS).
module Strelka::HTTPRequest::CORS


	### Add some instance variables to the request object.
	def initialize( * ) # :notnew:
		super
		@origin = nil
	end


	######
	public
	######

	### Return the URI in the Origin header (if the request has one) as a
	### URI object. If the request doesn't have an Origin: header, returns
	### nil.
	def origin
		unless @origin
			origin_uri = self.headers.origin or return nil
			@origin = URI( origin_uri )
		end

		return @origin
	end


	### Returns +true+ if the request contains an Origin header whose
	### URI has a host that's different than its Host: header.
	def cross_origin?
		return self.origin && self.headers.host != self.origin.host
	end
	alias_method :is_cross_origin?, :cross_origin?


	### Returns +true+ if the receiver is a CORS preflight request.
	def preflight?
		return self.origin &&
			self.verb == :OPTIONS &&
			self.header.access_control_request_method
	end
	alias_method :is_preflight?, :preflight?


end # module Strelka::HTTPRequest::CORS


