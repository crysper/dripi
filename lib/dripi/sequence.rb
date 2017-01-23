
module Dripi::Sequence
  def self.included(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)
    base.instance_eval do
      required_methods :dripable_id,:dripable_type,:current_id,:paused_at,:scheduled_at,:current_job_id

      belongs_to :current, class_name: Dripi.configuration.item
      has_one :template, through: :current, source: :drip_template
      belongs_to :dripable, polymorphic: true
      alias_method :drip_starter, :dripable
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def next
      self.current=current.next_drip_item
      update_attributes({:current_id=>current.try(:id),scheduled_at: nil, current_job_id: nil})
    end

    def pause
      #TODO
    end

    def paused?
      !paused_at.nil?
    end

    def trigger(current_triggerer,extra={})
      current.trigger(current_triggerer,self,extra) if current
    end

    def current_scheduled!(delay,job_id)
      update_attributes({:current_job_id=>job_id,:scheduled_at=>delay.to_i.minutes.from_now})
    end

    def current_scheduled?
      !scheduled_at.nil?
    end
  end



end
