module Doorkeeper
  module OAuth
    class Scopes

      def |(other)
        self.class.from_array(self.all | other.all)
      end
    end
  end
end
