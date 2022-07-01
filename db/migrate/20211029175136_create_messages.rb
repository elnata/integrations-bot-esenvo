class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.references :client, foreign_key: true
      t.text :message
      t.string :type

      t.timestamps
    end
  end
end
