Rails.application.routes.draw do
  root "prompts#index"
  resources :prompts do
    resources :reply
    resources :detail
    post 'ask_ai', to: 'ask_ai'
  end

end
