Rails.application.routes.draw do
  root "prompts#index"
  resources :prompts do
    resources :reply
    resources :detail
    post 'ask_ai', to: 'ask_ai'
  end

  get 'ideas', to: "ideas#index"
  post 'ideas', to: "ideas#create"
  post 'ideas/ask_ai', to: 'ideas#ask_ai'
  post 'ideas/send_email', to: 'ideas#send_email'

end
