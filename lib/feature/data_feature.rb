module Feature
  class DataFeature < BaseFeature

    def get key
      raise TypeError.new("#{name} does not responds to data with #{key}") unless key?(key)
      data[key.to_s]
    end

    def data key = nil
      return get_full_data unless key.present?
      raise TypeError.new("#{name} does not responds to data with #{key}") unless key?(key)

      begin
        return $rollout.get(name).data[key.to_s] || get_default(key)
      rescue Redis::CannotConnectError
        return get_default(key)
      end
    end

    def set_data data
      raise TypeError.new("#{name} does not responds to data with #{data.keys}") unless key?(data.keys)
      $rollout.set_feature_data name, data
    end

    def set_key key, value
      raise TypeError.new("#{name} does not responds to data with #{key}") unless key?(key)
      $rollout.set_feature_data name, { key.to_s => value}
    end

    def permitted_attributes
      return data.keys
    end

    def type
      return :data
    end

    def update args={}
      args.map do |key, value|
        self.set_key key, value
      end
    end

  private

    def key? key
      data_keys.include? key
    end

    def get_default key
      ::Feature.get_default(name, key)
    end

    def data_keys
      ::Feature.data_keys(name)
    end

    def get_full_data
      data_hash = {}

      data_keys.map do |k|
        data_hash[k] = data(name, k)
      end

      return data_hash
    end
  end
end
