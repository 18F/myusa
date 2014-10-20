module SimpleRole
  module SubjectMixin
    def grant_role!(role_name, object=nil)
      attrs = { name: role_name, authorizable: object }
      if self.roles.where(attrs).empty?
        self.roles << (Role.where(attrs).first || Role.where(attrs).create!)
      end
    end

    def has_role?(role_name, object=nil)
      !self.roles.where(name: role_name, authorizable: object).empty?
    end
  end
end
