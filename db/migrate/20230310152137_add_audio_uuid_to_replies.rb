class AddAudioUuidToReplies < ActiveRecord::Migration[7.0]
  def change
    add_column :replies, :audio_uuid, :string
  end
end
