module Dripi::Item
  def self.included(base)
    base.include(InstanceMethods)
    base.instance_eval do
      required_methods :execute_action!,:execution_test?,:trigger_test?,:trigger_delay,:position
      belongs_to :drip_template, class_name: Dripi.configuration.template, foreign_key:Dripi.configuration.template_foreign_key
      acts_as_list scope: :drip_template
    end
  end
  module InstanceMethods
    def next_drip_item
      lower_item
    end

    def prev_drip_item
      higher_item
    end

    def trigger(current_triggerer,sequence,extra={})
       return false if sequence.scheduled?
       return false if !trigger_test?(current_triggerer,sequence,extra)
       schedule(current_triggerer,sequence,extra)
    end

    def schedule(current_triggerer,sequence,extra)
      job=set_job(current_triggerer,sequence,extra)
      sequence.scheduled!(trigger_delay,job.provider_job_id) if job.provider_job_id
    end

    def execute(current_triggerer,sequence,extra={})
       return false if !execution_test?(current_triggerer,sequence,extra)
       result=execute_action!(current_triggerer,sequence,extra)
       sequence.next if result
    end

    def execute_(current_triggerer_,sequence_,extra_)
      execute(Dripi._obj(current_triggerer_),
              Dripi._obj(sequence_),
              Dripi._obj(extra_))
    end

    private
    def set_job(current_triggerer,sequence,extra)
      payload=[Dripi.obj_(self),
               Dripi.obj_(current_triggerer),
               Dripi.obj_(sequence),
               Dripi.obj_(extra)]

      return Dripi.configuration.job.constantize.set(wait: trigger_delay.try(:minutes)).perform_later(*payload)
    end
  end


end
