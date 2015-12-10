Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }
  
  resources :places do 
      resources :pictures, only: [:destroy] 
  end 
  root 'places#index'
  
  get 'you' => 'places#your_places', as: 'current_user_places'
end
