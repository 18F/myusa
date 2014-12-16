module TwoFactor
  module ActiveRecordMixin
    def two_factor(*strategies)
      strategies.each do |strategy|
        self.include("TwoFactor::Models::#{strategy.to_s.camelize}".constantize)
      end
    end
  end
end

ActiveRecord::Base.extend(TwoFactor::ActiveRecordMixin)
