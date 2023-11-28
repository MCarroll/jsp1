class CreatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.integer :amount, null: false, default: 0
      t.string :interval, null: false
      if t.respond_to? :jsonb
        t.jsonb :details
      else
        t.json :details
      end

      t.timestamps
    end
  end
end
