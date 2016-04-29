Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
  resources :outages do
    collection do
      OutagesController::CALENDAR_VIEWS.each do |view|
        get view
      end
    end
  end

  root 'home#index'
end
