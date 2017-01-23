
module Dripi::Sequence
  def self.included(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)
    base.instance_eval do
      required_methods :dripable_id,:dripable_type,:current_id,:status,:scheduled

      belongs_to :current, class_name: Dripi.configuration.item
      has_one :template, through: :current, source: :drip_template
      belongs_to :dripable, polymorphic: true
      alias_method :drip_starter, :dripable
    end
  end
  module ClassMethods
    private
    def item_extension(__options)
    end
  end
  module InstanceMethods
    def next
      self.current=current.next_drip_item
      update_attributes({:current_id=>current.try(:id),scheduled: nil})
    end

    def trigger(current_triggerer,extra={})
      current.trigger(current_triggerer,self,extra) if current
    end

    def current_scheduled!
      update_column(:scheduled,current.trigger_delay)
    end

    def current_scheduled?
      self.scheduled
    end
  end



end
