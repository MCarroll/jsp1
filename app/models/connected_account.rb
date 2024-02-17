class ConnectedAccount < ApplicationRecord
  include Token
  include Oauth

  belongs_to :owner, polymorphic: true
end
