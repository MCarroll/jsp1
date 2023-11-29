class CreateApiTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :api_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token
      t.string :name
      if t.respond_to? :jsonb
        t.jsonb :metadata
      else
        t.json :metadata
      end
      t.boolean :transient, default: false
      t.datetime :last_used_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :api_tokens, :token, unique: true
  end
end
