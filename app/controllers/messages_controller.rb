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

        # response = Response.new

        # speak_body = 'Hello, you just received your first call'
        # response.addSpeak(speak_body)
        # xml = PlivoXML.new(response)   

        # puts xml.to_xml() # Prints the XML
        # content_type "application/xml"
        # return xml.to_s() # Returns the XML


        response = Response.new

        first_speak_body = 'Please leave a message after the beep. Press the star key when done.'
        response.addSpeak(first_speak_body)

        params = {
            maxLength: '30',
            finishOnKey: '*'
        }
        response.addRecord(params)

        second_speak_body = 'Recording received.'
        response.addSpeak(second_speak_body)

        xml = PlivoXML.new(response)
        xml.to_xml
        puts "!!!!!!!!!******!!!!!!!!!"
        puts "!!!!!!!!!******!!!!!!!!!"
        puts xml
        puts response
        puts "!!!!!!!!!******!!!!!!!!!"
        puts "!!!!!!!!!******!!!!!!!!!"

        content_type "application/xml"
        return xml.to_s
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
# Vim cheat sheet:  https://vim.rtorr.com/
# 2. EDITOR="vi" bin/rails credentials:edit
# 3. :wq to save and quit vim

# Confirm credentials are updated
# 5. rails credentials:show  

# encountered issues using any editor other than VIM
# refrence stack overflow:
# https://stackoverflow.com/questions/54842820/cant-edit-credentials-rails-5-2

# faef02357c36f23624d0e91b838ba5f55721fa02cc85b0de35a6bb3d425b4eb0202dbfe79dc943d7fd9b3458367b9ff570b90e804b98507f8502a53a39f11c4f
# tuaKqaYKMYOsB0koY6LdM+Y7EbLrGWWjtYrqq0PtKdvcF3zcnBltkNshVl24S9HS4NrPp9fxY1Be5ea0F8sl6rAxKCAahE3Fh8f/lEunfc46LkO3fkWrDIloTaY7zzcGJD1lHGLNbPWkA5Tc+CzdT4U8BTWNF5gM+NmYFxhwWgV0CW+1jfgzYxJIy7eW+/S3sCBJ0T+ZbDIVMBAX4gv7eEKzYv2hMBVfXa9b72CNpIext2MEnTzX8I+aZT5X6wnIVKnMT0fTx/X8QQfFgDaTNoAuZDQcadHHmhMiCDb/Xcb75fIS9jRRYiLpKGdBUDsab8eUioBP0dDZXRo+LEJzcD0vQLnKR/XO4DUbQDJK2OtLjy1ZnFzGTfPQwRxPOX8E5pP1lW41+U0nHmtX8ueHzrJJ30qDqSTEM3sAgHb5LrthObqw8dByjYmegqC6pcx4598Ued3Q4DtvZhj9OuQ37Lew4xTcNHF7KCO1QquOo8OvsOPNBE48n8o5EIsro9eymralKn1XoyWKf/D+gWbalNtfAjGt++b8Ms=--zo7qlkEatmZnulcD--k/GZpVr9Z9Jx7l0QBpAAPA==
# 6e189647a27548c715f3deb8d5e4e97f