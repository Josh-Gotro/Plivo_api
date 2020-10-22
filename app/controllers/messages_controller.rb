class MessagesController < ApplicationController

    def index
        messages = Message.all
        render json: messages.to_json
    end

    def create 
        message = Message.create(message_params)
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
            params.require(:message).permit(:content, :outbound, :inbound)
        end

end
