module Feature
  class FeaturesController < ApplicationController

    layout 'feature/application'

    skip_before_action :verify_authenticity_token, only: [:update]

    def index
      @features = ::Feature.all
    end

    def update
      feature = ::Feature.find params[:id]

      respond_to do |format|

        if feature.update feature_permitted_params(feature)
          format.json { render json: { feature: feature.to_h }, status: :ok }
        else
          format.json { render json: { feature: feature.to_h }, status: :unprocessable_entity }
        end
      end
    end

  protected

    def feature_permitted_params(feature)
      params.require(:feature).permit(feature.permitted_attributes)
    end

  end
end
