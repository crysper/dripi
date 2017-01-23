module Dripi::Template

  def self.included(base)
    base.instance_eval do
      has_many :items,-> { order('position ASC') }, class_name: Dripi.configuration.item, foreign_key: Dripi.configuration.template_foreign_key
    end
  end

end
