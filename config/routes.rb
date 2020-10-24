Rails.application.routes.draw do

  #RESTful routes
  resources :messages, only: [:index]

  #Custom routes
  post 'send', to: 'messages#send_sms'
  post 'accept', to: 'messages#accept_sms'
  
  #Websockets
  mount ActionCable.server => '/cable'
end
