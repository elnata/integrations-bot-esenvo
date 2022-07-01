Rails.application.routes.draw do
  get 'page/index'
  post 'whatsapp/index'
  post '/webhook' => 'whatsapp#webhook'
  get '/auth/facebook/callback', to: 'sessions#facebook'
  get '/sign-in', to: 'sign_in#index'
  get '/successful', to: 'sign_in#successful'
  get '/politica', to: 'politica#politica'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
