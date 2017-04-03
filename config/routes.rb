Feature::Engine.routes.draw do
  resources :features
  root to: "features#index"
end
