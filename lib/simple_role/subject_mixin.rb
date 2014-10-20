module SimpleRole
  module SubjectMixin
    def has_role!(role_name, object=nil)
      attrs = { name: role_name, authorizable: object }
      if self.roles.where(attrs).empty?
        self.roles << (Role.where(attrs).first || Role.where(attrs).create!)
      end
    end

    def has_role?(role_name, object=nil)
      !self.roles.where(name: role_name, authorizable: object).empty?
    end

    def has_role_for?(object)
      !self.roles.where(authorizable: object).empty?
    end
  end
end
