module Doorkeeper::OAuth::Helpers::ScopeChecker
  def self.matches?(current_scopes, scopes)
    scopes.all? {|s| current_scopes.include?(s) }
  end
end
