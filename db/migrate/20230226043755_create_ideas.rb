class CreateIdeas < ActiveRecord::Migration[7.0]
  def change
    create_table :ideas do |t|
      t.string :city
      t.string :thing
      t.string :oblique
      t.string :style
      t.text :answer

      t.timestamps
    end
  end
end
