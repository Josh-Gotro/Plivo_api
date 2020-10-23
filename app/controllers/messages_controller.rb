class MessagesController < ApplicationController

    def index
        messages = Message.all
        render json: messages.to_json
    end

    def create 
        # auth_id = Rails.application.credentials.plivo[:auth_id]
        # auth_token = Rails.application.credentials.plivo[:auth_token]
        message = Message.create(message_params)

        # convert auth_id and auth_token to string?
        # client = RestClient.new(auth_id.to_s, auth_token.to_s)
        # message_created = client.messages.create(
        #     '+15125185935',
        #     `+#{params[:yourphone]}`,
        #     # %w[+15127448789],
        #     `+#{params[:content]}`
        # )

        if message.valid?
            render json: message
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
