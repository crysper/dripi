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

      #  pp self.sidekiq_worker_class
       return false if sequence.current_scheduled?
       return false if !trigger_test?(current_triggerer,sequence.drip_starter,extra)
       if trigger_delay>0
         schedule(current_triggerer,sequence,extra)
       else
         execute(current_triggerer,sequence,extra)
       end
    end

    def schedule(current_triggerer,sequence,extra)
      sequence.current_scheduled!
      set_sidekiq_worker(Oh.obj_to_s(current_triggerer),Oh.obj_to_s(sequence),Oh.oh_to_s(extra))
    end

    def execute_s(current_triggerer_s,sequence_s,extra_s)
      execute(Oh.s_to_obj(current_triggerer_s),Oh.s_to_obj(sequence_s),Oh.s_to_oh(extra_s))
    end

    def execute(current_triggerer,sequence,extra={})
       return false if !execution_test?(current_triggerer,sequence.drip_starter,extra)
       result=execute_action!(current_triggerer,sequence,extra)
       sequence.next if result
    end

    private
    def set_sidekiq_worker(current_triggerer_s,sequence_s,extra_s)
      # pp self.sidekiq_worker_class.
      # sidekiq_worker_class.class_eval do
      #   define_method(:perform) do
      #     puts var
      #   end
      # end
      # sidekiq_worker_class.perform_in(3.minutes,current_triggerer_s,sequence_s,extra_s)
      # # execute_s(current_triggerer_s,sequence_s,extra_s)
    end
  end

  module ClassMethods
      def item_extension(__options)
        define_method(:sidekiq_worker_class) do
           __options[:sidekiq_worker]
        end
    end
  end

end
