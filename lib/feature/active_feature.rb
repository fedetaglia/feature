module Feature
  class ActiveFeature < BaseFeature

    def active?
      begin
        return $rollout.active?(name) if $rollout.features.include? name.to_sym
        return ::Feature.get_default_active(name)
      rescue Redis::CannotConnectError
        return ::Feature.get_default_active(name)
      end
    end

    def activate
      $rollout.activate name
    end

    def deactivate
      $rollout.deactivate name
    end

    def permitted_attributes
      [ :active ]
    end

    def type
      return :boolean
    end

    def update args={}
      return activate   if args[:active] == 'true' && !active?
      return deactivate if args[:active] == 'false' && active?
      return false
    end

  end
end
