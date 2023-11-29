class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.belongs_to :account, null: false
      t.belongs_to :recipient, polymorphic: true, null: false
      t.string :type
      if t.respond_to? :jsonb
        t.jsonb :params
      else
        t.json :params
      end
      t.datetime :read_at

      t.timestamps
    end
  end
end
