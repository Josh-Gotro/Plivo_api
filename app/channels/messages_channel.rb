class MessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "messages_channel"
  end

  def unsubscribed
    raise NotImplementedError
  end
end
