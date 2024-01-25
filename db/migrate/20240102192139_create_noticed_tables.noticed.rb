# This migration comes from noticed (originally 20231215190233)
class CreateNoticedTables < ActiveRecord::Migration[6.1]
  class Notification < ActiveRecord::Base
    self.inheritance_column = nil
  end

  def self.up
    create_table :noticed_events do |t|
      t.belongs_to :account
      t.string :type
      t.belongs_to :record, polymorphic: true
      if t.respond_to?(:jsonb)
        t.jsonb :params
      else
        t.json :params
      end

      t.timestamps
    end

    create_table :noticed_notifications do |t|
      t.belongs_to :account
      t.string :type
      t.belongs_to :event, null: false
      t.belongs_to :recipient, polymorphic: true, null: false
      t.datetime :read_at
      t.datetime :seen_at

      t.timestamps
    end

    # Migrate notifications to new tables
    Notification.find_each do |notification|
      attributes = notification.attributes.slice("type", "account_id", "created_at", "updated_at").with_indifferent_access
      attributes[:type] = "Account::AcceptedInviteNotifier" if attributes[:type] == "AcceptedInvite"
      attributes[:type] = attributes[:type].sub("Notification", "Notifier")
      attributes[:params] = Noticed::Coder.load(notification.params)
      attributes[:params] = {} if attributes[:params].try(:has_key?, "noticed_error") # Skip invalid records
      attributes[:notifications_attributes] = [{
        account_id: notification.account_id,
        type: "#{attributes[:type]}::Notification",
        recipient_type: notification.recipient_type,
        recipient_id: notification.recipient_id,
        seen_at: notification.read_at,
        read_at: notification.interacted_at,
        created_at: notification.created_at,
        updated_at: notification.updated_at
      }]
      Noticed::Event.create(attributes)
    end

    # Uncomment after testing the migration
    # drop_table :notifications
  end

  def self.down
    drop_table :noticed_events
    drop_table :noticed_notifications
  end
end
