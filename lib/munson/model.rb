# module Munson
#   module Model
#     extend ActiveSupport::Concern
#
#     included do
#       self.include Munson::Resource
#     end
#
#     class_methods do
#       def has_many(*);end;
#       def has_one(*);end;
#       def belongs_to(*);end;
#     end
#   end
# end
