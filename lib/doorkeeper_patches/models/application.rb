class Doorkeeper::Application
  include Doorkeeper::Models::Scopes

  has_many :memberships, foreign_key: 'oauth_application_id', dependent: :destroy
  has_many :members, through: :memberships, source: :user

  has_many :owners, -> { where 'memberships.member_type' => 'owner' }, through: :memberships, source: :user
  has_many :developers, -> { where 'memberships.member_type' => 'developer' }, through: :memberships, source: :user

  scope :public?, -> { where public: true }
  scope :private?, -> { where public: false }

  scope :requested_public, -> { where.not(requested_public_at: nil) }

  validate do |a|
    return if a.scopes.nil?
    unless Doorkeeper::OAuth::Helpers::ScopeChecker.valid?(a.scopes_string.to_s, Doorkeeper.configuration.scopes)
      errors.add(:scopes, 'Invalid scope')
    end
  end

  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  audit_on :create

  def owner_emails=(val)
    email_list = val.split(' ')
    self.owners = User.where("email in (?)", email_list)
    super
  end

  def developer_emails=(val)
    email_list = val.split(' ')
    self.developers = User.where("email in (?)", email_list)
    super
  end

end
