Rails.application.routes.draw do
  get "time_zone/edit"

  get "time_zone/update"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => "/cable"
  resources :outages do
    collection do
      OutagesController.calendar_views.each do |view|
        get view
      end
    end
  end

  resources :configuration_items

  get "/time_zone", to: "time_zone#edit"
  post "/time_zone/edit", to: "time_zone#update"

  root "home#index"
end
