module Feature
  class BaseFeature

    attr_accessor :name, :description

    def initialize name, description = nil
      @name = name
      @description = description
    end

    def boolean?
      type == 'boolean'
    end

    def data?
      type == 'data'
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