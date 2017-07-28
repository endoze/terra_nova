require 'hashie'

class HashWithIndifferentAccess < Hash
  include Hashie::Extensions::MergeInitializer
  include Hashie::Extensions::IndifferentAccess
end
