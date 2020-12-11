include Plivo



class MessagesController < ApplicationController
    include Plivo::XML
    include Plivo::Exceptions
    skip_before_action :verify_authenticity_token
    auth_id = Rails.application.credentials.altplivo[:auth_id]
    auth_token = Rails.application.credentials.altplivo[:auth_token]
    CLIENT = RestClient.new(auth_id, auth_token)

    def index
        messages = Message.all
        render json: messages.to_json, include: "**"
    end

    def send_mms

        return_message = CLIENT.messages.create(
        message_params[:To], 
        [message_params[:From]], 
        "Thanks!")

        puts return_message

        # response = Response.new

        # prms = {
        #     src: message_params[:From],
        #     dst: message_params[:To],
        #     type: 'sms',
        # }

        # message_body = 'got it, thank you'
        # response.addMessage(message_body, prms)
        # xml = PlivoXML.new(response)
        # puts xml.to_xml

    end

    def phone_voice
        response = Response.new

        first_speak_body = 'Please leave a message after the beep. Press the star key when done.'
        response.addSpeak(first_speak_body)

        params = {
            action: '',
            maxLength: '30',
            finishOnKey: '*'
        }
        response.addRecord(params)

        second_speak_body = 'Recording received.'
        response.addSpeak(second_speak_body)

        xml = PlivoXML.new(response)
        puts xml.to_xml
        rescue PlivoXMLError => e
            puts 'Exception: ' + e.message
        
    end


    def send_sms
        # Create outgoing message from client request. 
        message = Message.new(
            MessageUUID: "",
            To: message_params[:To], 
            Text: message_params[:Text], 
            From: message_params[:From], 
            isoutgoing: message_params[:isoutgoing])

        # If no errors, Post message to Plivo API.
        if message.valid?
            message_created = CLIENT.messages.create(
                message_params[:From], 
                [message_params[:To]], 
                message_params[:Text])

        # Attach returned MessagueUUID to local record
            message.update(MessageUUID: message_created.message_uuid[0])
            render json: message
        end 
    end
    
    def accept_sms
        # Accept incoming message and persist to local API
        message = Message.create(
            MessageUUID: message_params[:MessageUUID],
            Text: message_params[:Text], 
            From: message_params[:From], 
            To: params[:To], 
            isoutgoing: false)

        # If no errors occur in new message, broadcast to React client.  
        if message.valid?
            ActionCable.server.broadcast 'messages_channel', message
        end
    end

    def log_sms
        # Request message detail records for range: <= & >=  dates provided.
        response = CLIENT.messages.list(
            message_time__lte: message_params[:lte],
            message_time__gte: message_params[:gte],
            limit: 20,
            offset: 0,
        )

        # map over returned records and search local records for SMS that match MessageUUID
        uuids = response[:objects].map {|msg| msg.message_uuid}
        messages = uuids.map do |uuid| 
            # binding.pry
            Message.find_by(MessageUUID: uuid)
        end
        render json: messages
    end

    private
    # Protect attributes from end-user assignment. 
    # Action Controller parameters forbidden in Active Model mass assignment until explicitly enumerated.
    def message_params
        params.permit(
        :message_time__gte, 
        :message_time__lte, 
        :gte, 
        :lte, 
        :content, 
        :isoutgoing, 
        :From, 
        :MessageIntent, 
        :MessageUUID, 
        :PowerpackUUID, 
        :Text, 
        :text,
        :To, 
        :TotalAmount, 
        :TotalRate, 
        :Type, 
        :Units,
        :MediaUrl,
        :media_urls,
        :Body
        )
    end
end


### To update secret credentials ###
# 1. delete master.key and credentials.yml

# Use Vim to update
# Vim cheat sheet:  https://www.radford.edu/~mhtay/CPSC120/VIM_Editor_Commands.html
# 2. EDITOR="vi" bin/rails credentials:edit
# 3. :wq to save and quit vim

# Confirm credentials are updated
# 5. rails credentials:show  

# encountered issues using any editor other than VIM
# refrence stack overflow:
# https://stackoverflow.com/questions/54842820/cant-edit-credentials-rails-5-2