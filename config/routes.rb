Rails.application.routes.draw do
  resource :session, only: %i[new create destroy]
  resource :registration, only: %i[new create]

  resources :job_applications do
    collection { get :board }
    member { patch :move }
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#show"
end
