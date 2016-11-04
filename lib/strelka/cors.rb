# -*- ruby -*-
# vim: set nosta noet ts=4 sw=4:
# encoding: utf-8


require 'strelka' unless defined?( Strelka )


module Strelka::CORS

	# The library version
	VERSION = '0.0.1'

	# Version control revision
	REVISION = %q$Revision$


	require 'strelka/app/cors'
	require 'strelka/httprequest/cors'
	require 'strelka/httpresponse/cors'

end # module Strelka::CORS

