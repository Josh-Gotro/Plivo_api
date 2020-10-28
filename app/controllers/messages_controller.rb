include Plivo

class MessagesController < ApplicationController
    skip_before_action :verify_authenticity_token
    auth_id = Rails.application.credentials.plivo[:auth_id]
    auth_token = Rails.application.credentials.plivo[:auth_token]
    CLIENT = RestClient.new(auth_id, auth_token)

    def index
        messages = Message.all
        render json: messages.to_json, include: "**"
    end

    def send_sms
        message = Message.new(
            MessageUUID: "",
            To: message_params[:To], 
            Text: message_params[:Text], 
            From: message_params[:From], 
            isoutgoing: message_params[:isoutgoing])

        if message.valid?
            message_created = CLIENT.messages.create(
                message_params[:From], 
                [message_params[:To]], 
                message_params[:Text])
            message.update(MessageUUID: message_created.message_uuid[0])
            render json: message
        end 
    end
    
    def accept_sms
        message = Message.create(
            MessageUUID: message_params[:MessageUUID],
            Text: message_params[:Text], 
            From: message_params[:From], 
            To: params[:To], 
            isoutgoing: false)

        if message.valid?
            ActionCable.server.broadcast 'messages_channel', message
        end
    end

    def log_sms
        response = CLIENT.messages.list(
            message_time__lte: message_params[:lte],
            message_time__gte: message_params[:gte],
            limit: 20,
            offset: 0,
        )
        uuids = response[:objects].map {|msg| msg.message_uuid}
        messages = uuids.map do |uuid| 
            # binding.pry
            Message.find_by(MessageUUID: uuid)
        end
        render json: messages
    end

private
    def message_params
        # params.require(:message).permit(:content, :myphone, :yourphone, :isoutgoing)
            params.permit(:message_time__gte, :message_time__lte, :gte, :lte, :content, :isoutgoing, :From, :MessageIntent, :MessageUUID, :PowerpackUUID, :Text, :To, :TotalAmount, :TotalRate, :Type, :Units)
    end
end