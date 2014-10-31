module SimpleRole
  module SubjectMixin
    def grant_role!(role_name, object=nil)
      return if self.has_role?(role_name, object)
      self.roles.push(Role.where(name: role_name, authorizable: object).first_or_create!)
    end

    def revoke_role!(role_name, object=nil)
      self.roles.delete(Role.where(name: role_name, authorizable: object))
    end

    def has_role?(role_name, object=nil)
      self.roles.exists?(name: role_name, authorizable: object)
    end
  end
end
