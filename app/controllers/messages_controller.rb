include Plivo


class MessagesController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
        messages = Message.all
        render json: messages.to_json, include: "**"
    end

    def send_sms
        auth_id = Rails.application.credentials.plivo[:auth_id]
        auth_token = Rails.application.credentials.plivo[:auth_token]
        client = RestClient.new(auth_id.to_s, auth_token.to_s)

        message = Message.new(
            MessageUUID: "",
            To: message_params[:To], 
            Text: message_params[:Text], 
            From: message_params[:From], 
            isoutgoing: message_params[:isoutgoing])

        if message.valid?
            message_created = client.messages.create(
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

private
    def message_params
        # params.require(:message).permit(:content, :myphone, :yourphone, :isoutgoing)
            params.permit(:content, :myphone, :yourphone, :isoutgoing, :From, :MessageIntent, :MessageUUID, :PowerpackUUID, :Text, :To, :TotalAmount, :TotalRate, :Type, :Units)
    end
end