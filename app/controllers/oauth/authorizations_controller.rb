
# Oauth::AuthorizationsController
class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
  def new
    # Check for address and address2
    pre_auth_scopes = pre_auth.scopes.to_a
    scopes = insert_extra_scope pre_auth_scopes,
                                'profile.address',
                                'profile.address2'

    # Sort array of scopes according to requirements
    pre_auth_scopes = scopes.sort_by do |x|
      SCOPE_GROUPS.map { |k| k[1] }.flatten.index x
    end

    @pre_auth_groups = create_groups pre_auth_scopes
    super
  end

  def create
    params[:scope] = params[:scope].join(' ')
    super
  end

  private

  def insert_extra_scope(arry, first, second)
    arry.push second if arry.include?(first) && !arry.include?(second)
    arry
  end

  def create_groups(pre_auth_scopes)
    pre_auth_groups = []

    SCOPE_GROUPS.keys.each do |group|
      inter = pre_auth_scopes & SCOPE_GROUPS[group]
      next if inter.empty?
      pre_auth_groups.push(
        name:   group,
        scopes: inter
      )
    end
    pre_auth_groups
  end
end
