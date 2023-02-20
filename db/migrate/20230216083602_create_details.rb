class CreateDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :details do |t|
      t.string :imgname
      t.string :imglink
      t.text :description
      t.references :prompt, null: false, foreign_key: true

      t.timestamps
    end
  end
end
