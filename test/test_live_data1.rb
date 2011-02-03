require 'helper'
require 'earth'

class TestLiveData1 < Test::Unit::TestCase
  def setup
    super
    # get the real gem path so we can fake it in fakefs (/usr/local/rvm/gems/ruby-1.8.7-head/gems/earth-0.3.11/lib/earth)
    earth_gem_path = ::File.expand_path(::File.join(::File.dirname(::Gem.required_location('earth', 'earth.rb')), '..'))
    
    FakeFS.activate!
    FileUtils.mkdir_p earth_gem_path

    # FAKING RESOURCES
    # fake earth.rb so that Gem.required_path can find it
    File.open(File.join(earth_gem_path, 'lib', 'earth.rb'), 'w') { |f| f.write "module Earth; end" }
    
    # fake what looks like a resource
    fake_resource_path = File.join earth_gem_path, 'lib', 'earth', 'live_data1_resource.rb'
    File.open(fake_resource_path, 'w') { |f| f.write "class ::LiveData1Resource < ActiveRecord::Base; end"}
    eval File.read(fake_resource_path) unless defined?(::LiveData1Resource)
    
    # fake what looks like a beta resource
    fake_beta_resource_path = File.join earth_gem_path, 'lib', 'earth', 'live_data1_beta_resource.rb'
    File.open(fake_beta_resource_path, 'w') { |f| f.write "class ::LiveData1BetaResource < ActiveRecord::Base; BETA = true; end"}
    eval File.read(fake_beta_resource_path) unless defined?(::LiveData1BetaResource)

    # FAKING DATASETS
    ::Rails.root = '/data/data1/current'
    eval "class ::Dataset; end"
    
    # fake what looks like a dataset
    fake_dataset_path = File.join ::Rails.root, 'app', 'models', 'live_data1_dataset.rb'
    File.open(fake_dataset_path, 'w') { |f| f.write "class ::LiveData1Dataset < Dataset; end"}
    eval File.read(fake_dataset_path) unless defined?(::LiveData1Dataset)
    
    # fake what looks like a beta dataset
    fake_beta_dataset_path = File.join ::Rails.root, 'app', 'models', 'live_data1_beta_dataset.rb'
    File.open(fake_beta_dataset_path, 'w') { |f| f.write "class ::LiveData1BetaDataset < Dataset; BETA = true; end"}
    eval File.read(fake_beta_dataset_path) unless defined?(::LiveData1BetaDataset)
    
    # FAKING A UNIVERSE
    FileUtils.mkdir_p '/etc/brighterplanet'
    File.open('/etc/brighterplanet/universe', 'w') { |f| f.write 'data1_production' }
  end
  
  def test_universe
    assert_equal 'data1_production', ::BrighterPlanet.metadata.send(:universe)
  end
  
  def test_authority
    assert ::BrighterPlanet.metadata.send(:data1_adapter).authority?('data1_production', 'resources')
    assert ::BrighterPlanet.metadata.send(:data1_adapter).authority?('data1_production', 'beta_resources')
  end
  
  def test_undifferentiated_resources
    assert_equal %w{LiveData1BetaResource LiveData1Resource}, ::BrighterPlanet.metadata.send(:data1_adapter).send(:undifferentiated_resources)
  end
  
  def test_resources
    assert_equal %w{LiveData1Resource}, ::BrighterPlanet.metadata.resources
  end

  def test_beta_resources
    assert_equal %w{LiveData1BetaResource}, ::BrighterPlanet.metadata.beta_resources
  end
  
  def test_datasets
    assert_equal %w{LiveData1Dataset}, ::BrighterPlanet.metadata.datasets
  end

  def test_beta_datasets
    assert_equal %w{LiveData1BetaDataset}, ::BrighterPlanet.metadata.beta_datasets
  end

  def test_what_must_come_from_other_sources
    assert_equal ::BrighterPlanet::Metadata::FALLBACK['emitters'], ::BrighterPlanet.metadata.emitters
  end
end
