# -*- ruby -*-
#encoding: utf-8

require 'strelka/httpresponse'


# CORS-related extensions for Strelka HTTP response objects.
module Strelka::HTTPResponse::CORS
	extend Strelka::MethodUtilities


	### Add some instance variables to the request object.
	def initialize( * ) # :notnew:
		@exposed_headers = []
		@allowed_headers = []
		@allowed_methods = []
		@allowed_origin = nil
		@credentials_allowed = false
		@access_control_max_age = nil
		super
	end


	######
	public
	######

	##
	# The Array of raw header names that should be exposed on the request.
	attr_accessor :exposed_headers

	##
	# The Array of raw header names that should be allowed on a preflighted request
	attr_accessor :allowed_headers

	##
	# The Array of raw HTTP verb names that should be allowed on a preflighted request
	attr_accessor :allowed_methods

	##
	# The origin that should be allowed by the response.
	attr_reader :allowed_origin

	##
	# The number of seconds a preflight request can be cached
	attr_accessor :access_control_max_age


	##
	# Whether or not credentials are allowed in the preflighted request
	attr_predicate_accessor :credentials_allowed


	### Set the allowed origin for the response.
	def allow_origin( new_origin )
		@allowed_origin = new_origin
	end


	### Set the headers of the response to indicate that any Origin is allowed.
	def allow_any_origin
		self.allow_origin( '*' )
	end


	### Add +header_names+ to the list of headers that should be exposed in the
	### response.
	def expose_headers( *header_names )
		self.exposed_headers ||= []
		self.exposed_headers += header_names
	end
	alias_method :expose_header, :expose_headers


	### Add +header_names+ to the list of headers that should be allowed in a
	### preflighted request.
	def allow_headers( *header_names )
		self.allowed_headers ||= []
		self.allowed_headers += header_names
	end
	alias_method :allow_header, :allow_headers


	### Add +verbs+ to the list of HTTP methods that should be allowed in a
	### preflighted request.
	def allow_methods( *verbs )
		self.allowed_methods ||= []
		self.allowed_methods += verbs
	end
	alias_method :allow_method, :allow_methods


	### Allow credentials in a preflighted request.
	def allow_credentials
		self.credentials_allowed = true
	end
	alias_method :allow_cookies, :allow_credentials


	### Add any CORS headers which have been set up to the receiving response.
	def add_cors_headers
		origin = self.allowed_origin || self.request.origin.to_s
		if self.set_header_if_present( :allow_origin, origin ) && origin != '*'
			if (( current_vary = self.header.vary ))
				self.header.vary = [current_vary, 'origin'].join( ', ' )
			else
				self.header.vary = 'origin'
			end
		end

		self.set_header_if_present( :allow_credentials, self.credentials_allowed? )

		if self.request.is_preflight?
			self.log.debug "Preflight response; adding -Allow- headers"
			self.set_header_if_present( :allow_headers, self.allow_headers_header )
			self.set_header_if_present( :allow_methods, self.allow_methods_header )
			self.set_header_if_present( :max_age, self.access_control_max_age_header )
		else
			self.log.debug "Regular response; adding -Expose- headers"
			self.header.access_control_expose_headers = self.expose_headers_header
		end
	end


	#########
	protected
	#########

	### If +value+ is not nil or empty, set the access control header with the
	### specified +name+ to it.
	def set_header_if_present( name, value )
		return unless value && !value.to_s.empty?
		header_name = "access_control_%s" % [ name ]
		self.header[ header_name ] = value.to_s

		return value
	end


	### Return the value that should be set on the Access-Control-Expose-Headers
	### header according to the response's #exposed_headers.
	def expose_headers_header
		return nil unless self.exposed_headers && !self.exposed_headers.empty?
		return self.exposed_headers.map do |header_name|
			header_name.to_s.split( /[\-_]+/ ).map( &:capitalize ).join( '-' )
		end.sort.uniq.join( ' ' )
	end


	### Return the value that should be set on the Access-Control-Allow-Headers
	### header according to the response's #allowed_headers.
	def allow_headers_header
		return nil unless self.allowed_headers && !self.allowed_headers.empty?
		return self.allowed_headers.map do |header_name|
			header_name.to_s.split( /[\-_]+/ ).map( &:capitalize ).join( '-' )
		end.sort.uniq.join( ' ' )
	end


	### Return the value that should be set on the Access-Control-Allow-Methods
	### header according to the response's #allowed_methods.
	def allow_methods_header
		return nil unless self.allowed_methods && !self.allowed_methods.empty?
		return self.allowed_methods.map( &:to_s ).sort.uniq.join( ' ' )
	end


	### Return the value that should be set on the Access-Control-Max-Age header
	### according to the responses #access_control_max_age
	def access_control_max_age_header
		max_age = self.access_control_max_age or return nil
		return max_age.to_i.to_s
	end

end # module Strelka::HTTPResponse::CORS
