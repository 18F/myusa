
# ScopeGroups
module ScopeGroups
  extend ActiveSupport::Concern

  included do
    helper_method :pre_auth_groups
  end

  private

  def insert_extra_scope(requested_scopes, allowed_scopes, first, second)
    requested_scopes.push second if requested_scopes.include?(first) &&
                                    !requested_scopes.include?(second) &&
                                     allowed_scopes.include?(second)
    requested_scopes
  end

  def create_scope_groups(pre_auth_scopes)
    scope_groups = []
    sets         = {}
    SCOPE_SETS.keys.each do |set_name|
      sets[set_name] = []
      SCOPE_SETS[set_name].each do |set|
        inter = pre_auth_scopes & set[:group]
        next if inter.empty?
        sets[set_name] << { label: set[:label], group: inter }
      end
      next if sets[set_name].empty?
      scope_groups.push(name: set_name, groups: sets[set_name])
    end
    scope_groups
  end

  def pre_auth_groups(pre_auth_scopes = @pre_auth.scopes, allowed_scopes = @pre_auth.client.try(:application).try(:scopes))
    scopes = []
    if allowed_scopes
      scopes = insert_extra_scope pre_auth_scopes.to_a,
                                  allowed_scopes,
                                  'profile.address',
                                  'profile.address2'
    end

    ordered_scopes = SCOPE_SETS.map { |k| k[1].map { |g| g[:group] } }.flatten
    # Sort array of scopes according to requirements
    pre_auth_scopes = scopes.sort_by do |x|
      ordered_scopes.index(x) || ordered_scopes.length
    end

    @pre_auth_groups = create_scope_groups pre_auth_scopes
  end
end
