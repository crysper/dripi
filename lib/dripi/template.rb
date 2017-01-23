module Dripi::Template

  def self.included(base)
    base.extend(ClassMethods)
    base.instance_eval do
      has_many :items,-> { order('position ASC') }, class_name: Dripi.configuration.item, foreign_key: Dripi.configuration.template_foreign_key
    end
  end

  module ClassMethods
    private
    def item_extension(__options)
    end
  end


end
