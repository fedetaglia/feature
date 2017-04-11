require "feature/engine"

module Feature
  class TypeError < StandardError; end
  class NotFeatureError < StandardError; end

  # CLASS METHODS #
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
      yml.keys.map{|key| Feature.new key }
    end

    def find feature
      all.detect{ |f| f.name == feature.to_s }
    end

    def active? feature
      raise NotFeatureError.new("#{feature} is not a valid feature.") unless is_feature? feature
      raise TypeError.new("#{feature} does not responds to active?") unless boolean? feature
      begin
        return $rollout.active?(feature) if $rollout.features.include? feature.to_sym
        return get_default_active(feature)
      rescue Redis::CannotConnectError
        return get_default_active(feature)
      end
    end

    def get_full_data feature
      raise NotFeatureError.new("#{feature} is not a valid feature.") unless is_feature? feature
      raise TypeError.new("#{feature} does not responds to get_data") unless data? feature

      data = {}
      yml[feature.to_s]['data'].keys.map do |k|
        data[k] = get_data(feature, k)
      end

      return data
    end

    def get_data feature, key
      raise NotFeatureError.new("#{feature} is not a valid feature.") unless is_feature?(feature)
      raise TypeError.new("#{feature} does not responds to get_data") unless data? feature
      raise TypeError.new("#{feature} does not responds to get_data with #{key}") unless key?(feature, key)
      begin
        return $rollout.get(feature).data[key.to_s] || get_default(feature, key)
      rescue Redis::CannotConnectError
        return get_default(feature, key)
      end
    end

    def activate feature
      raise NotFeatureError.new("#{feature} is not a valid feature.") unless is_feature?(feature)
      raise TypeError.new("#{feature} does not responds to active?") unless boolean? feature
      $rollout.activate feature
    end

    def deactivate feature
      raise NotFeatureError.new("#{feature} is not a valid feature.") unless is_feature?(feature)
      raise TypeError.new("#{feature} does not responds to active?") unless boolean? feature
      $rollout.deactivate feature
    end

    def set_data feature, data
      raise NotFeatureError.new("#{feature} is not a valid feature.") unless is_feature?(feature)
      raise TypeError.new("#{feature} does not responds to get_data") unless data? feature
      raise TypeError.new("#{feature} does not responds to get_data with #{data.keys}") unless key?(feature, data.keys)
      $rollout.set_feature_data feature, data
    end

    def set_key feature, key, value
      raise NotFeatureError.new("#{feature} is not a valid feature.") unless is_feature?(feature)
      raise TypeError.new("#{feature} does not responds to get_data") unless data? feature
      raise TypeError.new("#{feature} does not responds to get_data with #{key}") unless key?(feature, key)
      $rollout.set_feature_data feature, { "#{key}" => value}
    end

    def is_feature? feature
      yml[feature.to_s].present?
    end

    def boolean? feature
      yml[feature.to_s].keys.include? 'boolean'
    end

    def data? feature
      yml[feature.to_s].keys.include? 'data'
    end

    def key? feature, key
      return yml[feature.to_s]['data'].keys.include? key.to_s if key.is_a?(Symbol) || key.is_a?(String)
      key.each do |k|
        next unless yml[feature.to_s]['data'].keys.include? k.to_s
        return true
      end
      return false
    end

    def get_default_active feature
      yml[feature.to_s]['boolean'] == 'true' rescue false
    end

    def get_default feature, key
      return yml[feature.to_s]['data'][key.to_s]
    end

    def yml
      @yml ||= YAML.load_file("#{Rails.root.to_s}/config/feature.yml")
    end
  end

  class Feature
    # INSTANCE METHODS #
    attr_accessor :name

    def initialize name
      @name = name
    end

    def type
      ::Feature.send(:boolean?, name) ? "boolean" : "data"
    end

    def boolean?
      ::Feature.send(:boolean?, name)
    end

    def data?
      ::Feature.send(:data?, name)
    end

    def active?
      raise TypeError.new("#{name} does not responds to active?") unless boolean?
      ::Feature.active?(name)
    end

    def data
      raise TypeError.new("#{name} does not responds to data") unless data?
      ::Feature.get_full_data(name)
    end

    def get data_key
      raise TypeError.new("#{name} does not responds to get_data with #{data_key}") unless ::Feature.key?(name, data_key)
      data[data_key.to_s]
    end

    def activate
      raise TypeError.new("#{name} does not responds to activate") unless boolean?
      ::Feature.activate name
    end

    def deactivate
      raise TypeError.new("#{name} does not responds to deactivate") unless boolean?
      ::Feature.deactivate name
    end

    def update args={}
      if boolean?
        return activate if args[:active] == 'true' && !active?
        return deactivate if args[:active] == 'false' && active?
        return false
      else
        args.map do |key, value|
          ::Feature.set_key name, key, value
        end
      end
    end

    def permitted_attributes
      return [:active] if boolean?
      return data.keys if data?
    end

    def to_h
      return {
        name: name,
        type: type,
        data: (boolean? ? {active: active? } : data)
      }
    end
  end

end
