Rails.application.routes.draw do

  #RESTful routes
  resources :messages, only: [:index]

  #Custom routes
  post 'send', to: 'messages#send_sms'
  post 'phonecall', to: 'messages#phone_voice'
  post 'sendmms', to: 'messages#send_mms'
  post 'accept', to: 'messages#accept_sms'
  get 'smslog', to: 'messages#log_sms'

  #Websockets
  mount ActionCable.server => '/cable'
end
