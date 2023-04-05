class AddLocaleToIdeas < ActiveRecord::Migration[7.0]
  def change
    add_column :ideas, :locale, :string, default: "zh"
  end
end
