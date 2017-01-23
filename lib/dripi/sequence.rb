
module Dripi::Sequence
  def self.included(base)
    base.include(InstanceMethods)
    base.instance_eval do
      required_methods :dripable_id,:dripable_type,:current_id,:paused_at,:scheduled_at,:scheduled_job_id

      belongs_to :current, class_name: Dripi.configuration.item
      has_one :template, through: :current, source: :drip_template
      belongs_to :dripable, polymorphic: true
      alias_method :drip_starter, :dripable
    end
  end

  module InstanceMethods
    def next
      self.current=current.next_drip_item
      self.scheduled_at=nil
      self.scheduled_job_id=nil
      self.save
    end

    def pause
      #TODO
    end

    def paused?
      paused_at.present?
    end

    def trigger(current_triggerer,extra={})
      current.trigger(current_triggerer,self,extra) if current
    end

    def scheduled!(delay,job_id)
      self.scheduled_at=delay.to_i.minutes.from_now
      self.scheduled_job_id=job_id
      self.save
    end

    def scheduled?
      scheduled_at.present?
    end
  end



end
