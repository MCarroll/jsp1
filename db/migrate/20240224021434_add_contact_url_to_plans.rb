class AddContactUrlToPlans < ActiveRecord::Migration[7.1]
  def change
    add_column :plans, :contact_url, :string
  end
end
