module Dripi
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)
      desc "Creates Dripi initializer for your application"

      def copy_initializer
        template "dripi_initializer.rb", "config/initializers/dripi.rb"

        puts "Install complete! Truly Outrageous!"
      end

      def run_other_generators
        generate "model Drip::Item name:string trigger_delay:integer drip_template_id:integer:index position:integer"
        generate "model Drip::Sequence dripable_id:integer:index dripable_type:string current_job_id:string scheduled_at:datetime paused_at:datetime current_id:integer:index"
        generate "model Drip::template name:string"
        generate "job DripSequence"

        drip_item_file='app/models/drip/item.rb'
        drip_job_file='app/jobs/drip_sequence_job.rb'


        gsub_file drip_item_file, /class Drip::Item < ApplicationRecord\nend/ do |match|
        %Q{
class Drip::Item < ApplicationRecord

  def trigger_test?(current_triggerer,sequence,extra)
    drip_starter=sequence.drip_starter
    #specify conditions to test if the current sequence action should be scheduled or not

  end

  def execution_test?(current_triggerer,sequence,extra)
    drip_starter=sequence.drip_starter
    #specify conditions test if the current sequence action should be executed(after it has been scheduled and delay is over)

  end

  def execute_action!(current_triggerer,sequence,extra)
    drip_starter=sequence.drip_starter
    #the current sequence action to be executed. When this returns true the sequence will proceed to the next item

  end

end
          }
        end #if File.exists?(drip_item_file)

      if File.exists?(drip_job_file)
        inject_into_file drip_job_file, :after => "perform(*args)" do
          %Q{
    item=Dripi.s_to_obj(item_)
    item.execute_job(current_triggerer_,sequence_,extra_) if item
          }
        end
        gsub_file drip_job_file,'perform(*args)','perform(item_,current_triggerer_,sequence_,extra_)'
      end

    end




    end
  end
end
