require 'bundler/setup'
require 'brighter_planet_metadata'

require 'vcr'
VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :fakeweb
end

RSpec.configure do |c|
  c.extend VCR::RSpec::Macros
end
