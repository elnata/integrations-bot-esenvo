class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :facebook_uuid
      t.string :email
      t.string :id_token
      t.string :provider
      t.string :last_active_at

      t.timestamps
    end
  end
end
