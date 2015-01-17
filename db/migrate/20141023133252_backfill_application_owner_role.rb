class BackfillApplicationOwnerRole < ActiveRecord::Migration
  def up
    if Object.const_get(:Role)
      Doorkeeper::Application.all.each do |a|
        user = User.find(a.owner_id)
        role = Role.where(name: :owner, authorizable: a).first_or_create!

        if user && role && !user.roles.include?(role)
          user.roles.push(role)
        end
      end
    end
  end
end
