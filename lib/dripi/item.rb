module Dripi::Item
  def self.included(base)
    base.extend(ClassMethods)
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
       return false if sequence.current_scheduled?
       return false if !trigger_test?(current_triggerer,sequence,extra)
       schedule(current_triggerer,sequence,extra)
    end

    def schedule(current_triggerer,sequence,extra)
      sid=set_job(current_triggerer,sequence,extra)
      # pp sid
      sequence.current_scheduled!(trigger_delay,sid.provider_job_id) if sid
    end


    def execute(current_triggerer,sequence,extra={})
       return false if !execution_test?(current_triggerer,sequence,extra)
       result=execute_action!(current_triggerer,sequence,extra)
       sequence.next if result
    end

    def execute_job(current_triggerer_,sequence_,extra_)
      execute(Dripi.s_to_obj(current_triggerer_),Dripi.s_to_obj(sequence_),Dripi.s_to_oh(extra_))
    end

    private
    def set_job(current_triggerer,sequence,extra)
      payload=[Dripi.obj_to_s(self),
               Dripi.obj_to_s(current_triggerer),
               Dripi.obj_to_s(sequence),
               Dripi.oh_to_s(extra)]
               pp payload
      Dripi.configuration.job.constantize.set(wait: trigger_delay.try(:minutes)).perform_later(*payload)
    end
  end

  module ClassMethods
  end

end
