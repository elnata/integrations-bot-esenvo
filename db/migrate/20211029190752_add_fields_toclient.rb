class AddFieldsToclient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :human, :boolean
    add_column :clients, :hsm, :boolean
  end
end
