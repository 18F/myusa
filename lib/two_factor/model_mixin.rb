module TwoFactor
  module ActiveRecordMixin
    def two_factor(*strategies)
      strategies.each do |strategy|
        begin
          self.include("TwoFactor::Models::#{strategy.to_s.camelize}".constantize)
        rescue NoMethodError
          # Yes, this is an awful thing. Glad you noticed.
          # Short version: This mixin causes Rails to attempt to reach the DB
          # at initialization time, which is a bad thing if you're in the
          # compile stage rather than run stage (when trying to build a
          # droplet for Cloud Foundry) and you just want to precompile assets.
          # Longer discussion: https://github.com/18F/myusa/issues/636
        end
      end
    end
  end
end

ActiveRecord::Base.extend(TwoFactor::ActiveRecordMixin)
