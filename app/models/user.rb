class User < ApplicationRecord
  include ActionText::Attachable
  include TwoFactorAuthentication
  include User::Accounts
  include User::Agreements
  include User::Theme

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, andle :trackable
  devise(*[:database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable, (:omniauthable if defined? OmniAuth)].compact)

  has_noticed_notifications
  has_person_name

  # ActiveStorage Associations
  has_one_attached :avatar

  # Associations
  has_many :api_tokens, dependent: :destroy
  has_many :connected_accounts, as: :owner, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy
  has_many :notification_tokens, dependent: :destroy

  # We don't need users to confirm their email address on create,
  # just when they change it
  before_create :skip_confirmation!

  # Protect admin flag from editing
  attr_readonly :admin

  # Validations
  validates :name, presence: true
  validates :avatar, resizable_image: true

  # Replace with a search engine like Meilisearch, ElasticSearch, or pg_search to provide better results
  # Using arel matches allows for database agnostic like queries
  def self.search(query)
    case connection.adapter_name
    when "SQLite"
      first_name, last_name = query.split(" ", 2)
      if last_name.present?
        where(arel_table[:first_name].matches("%#{sanitize_sql_like(first_name)}%")).where(arel_table[:last_name].matches("%#{sanitize_sql_like(last_name)}%"))
      else
        where(arel_table[:first_name].matches("%#{sanitize_sql_like(query)}%")).or(where(arel_table[:last_name].matches("%#{sanitize_sql_like(query)}%")))
      end
    else
      where(arel_table[:name].matches("%#{sanitize_sql_like(query)}%"))
    end
  end

  # When ActionText rendering mentions in plain text
  def attachable_plain_text_representation(caption = nil)
    caption || name
  end
end
