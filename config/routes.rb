Rails.application.routes.draw do
  root "ideas#index"
  resources :prompts do
    resources :reply
    resources :detail
    post 'ask_ai', to: 'prompts#ask_with_embeddings'
  end
  post 'prompts/resemble_callback', to: 'prompts#async_callback_resemble'

  get 'ideas', to: "ideas#index"
  post 'ideas', to: "ideas#create"
  post 'ideas/ask_ai', to: 'ideas#ask_ai'
  post 'ideas/send_email', to: 'ideas#send_email'

end
