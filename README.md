# strelka-cors

home
: http://deveiate.org/projects/Strelka-CORS

code
: http://bitbucket.org/ged/Strelka-CORS

github
: https://github.com/ged/strelka-cors

docs
: http://deveiate.org/code/strelka-cors


## Description

This is still a work in progress.

This is a Strelka application plugin for describing rules for [Cross-Origin Resource Sharing (CORS)](http://www.w3.org/TR/cors/).

By default, the plugin has paranoid defaults, and doesn't do anything. You'll need to grant access to the resources you want to share.

To grant access, you declare one or more `access_control` blocks which can modify responses to matching access-control requests. All the blocks which match the incoming request's URI are called with the request and response objects in the order in which they're declared: 

	# Allow access to all resources from any origin by default
	access_control do |req, res|
		res.allow_origin '*'
		res.allow_methods 'GET', 'POST'
		res.allow_credentials
		res.allow_headers :content_type
	end


These are applied in the order you declare them, with each matching block passed the request if it matches. This happens before the application gets the request, so it can do any further modification it needs to, and so it can block requests from disallowed origins/methods/etc.

There are a number of helper methods added to the request and response objects for applying and declaring access-control rules when this plugin is loaded:


### `HTTPResponse#allow_origin <origin>+`

The `origin` parameter specifies a URI that may access the resource by setting the `Access-Control-Allow-Origin` header.

	access_control do |req, res|
		res.allow_origin 'http://acme.com/', 'http://www.acme.com/
		res.allow_origin( req.origin )
		res.allow_origin # same as above
		res.allow_origin '*'
	end


### `HTTPResponse#expose_headers`
Specify a whitelist of headers that browsers are allowed to access by setting the `Access-Control-Expose-Headers` header on responses.

	response.expose_headers :content_type, 'x-custom-header'


### `HTTPResponse#access_control_max_age`

Specify how long the results of a preflight request can be cached by setting the `Access-Control-Max-Age` header.


### `HTTPResponse#allow_credentials`

Specify whether or not a request can be made using credentials by setting the `Access-Control-Allow-Credentials` header on responses.


### `HTTPResponse#allow_methods`

Specifies the method or methods allowed when accessing the resource by setting the `Access-Control-Allow-Methods` header on responses.


### `HTTPResponse#allow_headers`

Specify the HTTP headers that can be used when making a request.





### Allow All Simple Requests

If you just want to allow simple (GET, HEAD, POST) requests to your application
from any origin, you can do it like so:

    require 'strelka/app'
    
    class MyApp < Strelka::App
        plugin :cors
        allow_origins '*'

        # The rest of your app

    end

This will add the appropriate header to outgoing responses.


## Installation

    gem install strelka-cors


## License

Copyright (c) 2013, FIX
All rights reserved.
