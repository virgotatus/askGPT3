class AddAlterQuestionsToDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :details, :alter_questions, :text
  end
end
