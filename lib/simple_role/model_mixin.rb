module SimpleRole
  module ModelMixin
    def acts_as_authorization_role(opts={})
      has_and_belongs_to_many :users
      belongs_to :authorizable, polymorphic: true
    end

    def acts_as_authorization_subject(opts={})
      has_and_belongs_to_many :roles
      include SubjectMixin
    end

    def acts_as_authorization_object(opts={})
      has_many :roles, as: :authorizable
    end
  end
end
