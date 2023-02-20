class AddDefaultValueToAlterQuestions < ActiveRecord::Migration[7.0]
  def change
    change_column_default :details, :alter_questions, from: nil, to: "wish me lucky and happy"
  end
end
