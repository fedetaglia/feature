Rails.application.routes.draw do
  mount Feature::Engine => "/feature"
end
