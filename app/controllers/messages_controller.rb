include Plivo

class MessagesController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
        messages = Message.all
        render json: messages.to_json
    end

    def create 
        message = Message.create(message_params)
        
        if message.valid?
            render json: message
            auth_id = (Rails.application.credentials.plivo[:auth_id]).to_s
            auth_token = (Rails.application.credentials.plivo[:auth_token]).to_s
    
            puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            # p `#{Rails.application.credentials.plivo[:auth_token]}`
            # p `#{Rails.application.credentials.plivo[:auth_id]}`
            puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            # convert auth_id and auth_token to string?
            client = RestClient.new(auth_id, auth_token)
            message_created = client.messages.create(
                '+15125185935',
                # `+#{params[:yourphone]}`,
                %w[+15127448789],
                "hi hi hi hi hi"
                # `+#{params[:content]}`
            )
        else
            render json: {errors: message.errors.full_messages}
        end
    end

    def show
        message = Message.find_by({id: params[:id]})
        # if message
            render json: message.to_json
        # else
            # render json: { "Your partner is in another castle"}
        # end 
    end

    private
        def message_params
            params.require(:message).permit(:content, :myphone, :yourphone, :isoutgoing)
        end

end

# Rails.application.credentials.plivo[:auth_id]
# Rails.application.credentials.plivo[:auth_token]
