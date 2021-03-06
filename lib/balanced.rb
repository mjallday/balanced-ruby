require 'uri'
require 'balanced/version' unless defined? Balanced::VERSION
require 'balanced/client'
require 'balanced/utils'
require 'balanced/base'
require 'balanced/resources'

module Balanced

  @client = nil
  @config = {
      :scheme => 'https',
      :host => 'api.balancedpayments.com',
      :port => 443,
      :version => '1',
  }

  class << self

    attr_accessor 'client'
    attr_accessor 'config'

    def configure(api_key=nil, options={})
      options = @config.merge! options
      @config = options
      @client = Balanced::Client.new(api_key, @config)
    end

    def get uri, params = {}
      self.client.get uri, params
    end

    def post uri, data = {}
      self.client.post uri, data
    end

    def put uri, data = {}
      self.client.put uri, data
    end

    def delete uri
      self.client.delete uri
    end

    def split_the_uri uri
      parsed_uri = URI.parse(uri)
      parsed_uri.path.sub(/\/$/, '').split('/')
    end

    def from_uri uri
      split_uri = split_the_uri(uri)
      # this is such an ugly hack, basically, we're trying to
      # see if we have the symbol that matches the capitalized
      #
      class_name = Balanced::Utils.classify(split_uri[-1])
      begin
        klass = Balanced.const_get class_name
      rescue NameError
        class_name = Utils.classify(split_uri[-2])
        klass = Balanced.const_get(class_name)
      end
      klass
    end

    def is_collection uri
      split_uri = split_the_uri(uri)
      class_name = Balanced::Utils.classify(split_uri[-1])
      begin
        Balanced.const_get class_name
      rescue NameError
        return false
      end
      true
    end
  end

  # configure on import so we don't have to configure for creating
  # an api key
  configure
end