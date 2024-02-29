class AddIndexToAccountInvitationForEmail < ActiveRecord::Migration[7.1]
  def change
    add_index :account_invitations, [:account_id, :email], unique: true

    # Remove redundant index
    remove_index :account_invitations, :account_id
  end
end
