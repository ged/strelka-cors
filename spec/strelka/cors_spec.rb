#!/usr/bin/env rspec -cfd

require_relative '../helpers'

require 'strelka/cors'


describe Strelka::CORS do

	it "knows what version of the library it is" do
		expect( described_class::VERSION ).to be_a( String ).and( match(/\A\d+\.\d+\.\d+\z/) )
	end

end

