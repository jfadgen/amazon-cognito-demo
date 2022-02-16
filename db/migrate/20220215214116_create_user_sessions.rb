class CreateUserSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :user_sessions do |t|
      t.string :id_token
      t.string :access_token
      t.string :refresh_token
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
