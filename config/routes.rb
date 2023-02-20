Rails.application.routes.draw do
  root "prompts#index"
  resources :prompts do
    resources :reply
    resources :detail
    get 'ask_ai', to: 'ask_ai'
  end

end
