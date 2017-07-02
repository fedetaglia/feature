require "feature/engine"
require "feature/base_feature"
require "feature/active_feature"
require "feature/data_feature"

module Feature
  class TypeError < StandardError; end
  class NotFeatureError < StandardError; end

  class << self
    def can_update?
      begin
        $redis.ping
        return true
      rescue Redis::CannotConnectError => e
        return false
      end
    end

    def all
      yml.keys.map do |key|
        feature_class(key).new key, yml[key]['description']
      end
    end

    def find key
      raise NotFeatureError unless is_feature?(key)
      return ActiveFeature.new key, yml[key.to_s]['description'] if boolean? key
      return DataFeature.new key, yml[key.to_s]['description']
    end

    def is_feature? feature
      yml[feature.to_s].present?
    end

    def feature_class feature
      boolean?(feature) ? ActiveFeature : DataFeature
    end

    def boolean? feature
      yml[feature.to_s].keys.include? 'boolean'
    end

    def data? feature
      yml[feature.to_s].keys.include? 'data'
    end

    def active? key
      object = find(key)
      raise TypeError.new("#{name} does not responds to active") if object.is_a? DataFeature
      object.active?
    end

    def data key, data
      object = find(key)
      raise TypeError.new("#{name} does not responds to data") if object.is_a? ActiveFeature
      object.data(data)
    end

    def get_default_active feature
      yml[feature.to_s]['boolean'] == 'true' rescue false
    end

    def get_default feature, key
      return unless data_keys(feature).include? key.to_s
      return yml[feature.to_s]['data'][key.to_s]
    end

    def data_keys feature
      yml[feature.to_s]['data'].keys
    end

  private

    def yml
      file.send(:[], Rails.env)
    end

    def file
      @file ||= YAML.load_file("#{Rails.root.to_s}/config/feature.yml")
    end

  end
end
