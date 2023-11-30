module Account::Domains
  extend ActiveSupport::Concern

  included do |base|
    base.const_set :RESERVED_DOMAINS, [Jumpstart.config.domain]
    base.const_set :RESERVED_SUBDOMAINS, %w[app help support]

    # To require a domain or subdomain, add the presence validation
    validates :domain, exclusion: {in: base.const_get(:RESERVED_DOMAINS), message: :reserved}, uniqueness: {allow_blank: true}
    validates :subdomain, exclusion: {in: base.const_get(:RESERVED_SUBDOMAINS), message: :reserved}, format: {with: /\A[a-zA-Z0-9]+[a-zA-Z0-9\-_]*[a-zA-Z0-9]+\Z/, message: :format, allow_blank: true}, uniqueness: {allow_blank: true}
  end
end
