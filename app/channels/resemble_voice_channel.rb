class ResembleVoiceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "voice_#{params[:uuid]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
