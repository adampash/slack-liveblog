class MessagesController < ApplicationController
  before_filter :set_cache_control_headers, only: [:show]

  def show
    @message = Message.find_cache params[:id]
    set_surrogate_key_header [@message.record_key]
  end

  def embed
    @embed = Embed.find_by(message_id: params[:id])
    if @embed.nil?
      render json: {}
    else
      render json: @embed
    end
  end
end
