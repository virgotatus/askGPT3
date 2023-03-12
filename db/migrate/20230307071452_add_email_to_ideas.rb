class AddEmailToIdeas < ActiveRecord::Migration[7.0]
  def change
    add_column :ideas, :email, :string
  end
end
