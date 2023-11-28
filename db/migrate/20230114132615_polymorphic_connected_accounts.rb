class PolymorphicConnectedAccounts < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :user_connected_accounts, column: :user_id
    remove_index :user_connected_accounts, column: :user_id
    rename_table :user_connected_accounts, :connected_accounts
    rename_column :connected_accounts, :user_id, :owner_id
    add_column :connected_accounts, :owner_type, :string
    add_index :connected_accounts, [:owner_id, :owner_type]

    # Backfill existing connected accounts
    ConnectedAccount.reset_column_information
    ConnectedAccount.update_all owner_type: "User"
  end
end
