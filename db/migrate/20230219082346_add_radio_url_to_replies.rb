class AddRadioUrlToReplies < ActiveRecord::Migration[7.0]
  def change
    add_column :replies, :radio_url, :string
  end
end
