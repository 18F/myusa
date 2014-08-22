
# ScopeGroups
module ScopeGroups
  extend ActiveSupport::Concern

  included do
    helper_method :pre_auth_groups
  end

  private

  def insert_extra_scope(arry, first, second)
    arry.push second if arry.include?(first) && !arry.include?(second)
    arry
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

  def pre_auth_groups(pre_auth_scopes = @pre_auth.scopes)
    orig_scopes = pre_auth_scopes.to_a
    scopes = insert_extra_scope orig_scopes,
                                'profile.address',
                                'profile.address2'
    ordered_scopes = SCOPE_SETS.map { |k| k[1].map { |g| g[:group] } }.flatten
    # Sort array of scopes according to requirements
    pre_auth_scopes = scopes.sort_by do |x|
      ordered_scopes.index(x) || ordered_scopes.length
    end

    @pre_auth_groups = create_scope_groups pre_auth_scopes
  end
end
