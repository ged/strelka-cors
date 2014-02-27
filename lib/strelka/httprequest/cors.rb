# -*- ruby -*-
#encoding: utf-8

require 'strelka/httprequest' unless defined?( Strelka::HTTPRequest )


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

end # module Strelka::HTTPRequest::CORS


