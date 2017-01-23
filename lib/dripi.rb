require "dripi/version"
require 'dripi/utils'
require 'dripi/template'
require 'dripi/sequence'
require 'dripi/item'
module Dripi
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?

  end
  def self.const_avai?(const)
    const.constantize rescue nil
  end
  def self.check_config
    configure if configuration.nil?
    raise NameError, "Template Class not initialized" if !const_avai?(configuration.template)
    raise NameError, "Sequence Class not initialized" if !const_avai?(configuration.sequence)
    raise NameError, "Item Class not initialized"     if !const_avai?(configuration.item)
    # raise NameError, "Worker Class not initialized"   if !defined?(config.worker.constantize)
  end

  class Configuration
    attr_accessor :template,:sequence,:item,:template_foreign_key,:worker_provider,:worker

    def initialize

      @template= 'Drip::Template'
      @sequence= 'Drip::Sequence'
      @item= 'Drip::Item'

      @template_foreign_key='drip_template_id'
      @worker_provider=:sidekiq
      @worker= ''
    end
  end

  module InstanceMethods
    def start_drip(template)
      itf=template.items.first
      seq=create_drip_sequence(current_id: itf.id)
      seq.trigger(nil)
      #triggering the first template action in the list
    end
  end


  module Initializers
    def acts_as_dripable(options={})
      Dripi.check_config

      include InstanceMethods
      include_drip_template
      include_drip_sequence
      include_drip_item

      has_one :drip_sequence, as: :dripable, class_name: Dripi.configuration.sequence

    end

    def include_drip_template
      template_class=Dripi.configuration.template.constantize
      template_class.include Template,Utils
      # template_class.send(:item_extension,options)
    end

    def include_drip_sequence
      sequence_class=Dripi.configuration.sequence.constantize
      sequence_class.include Sequence,Utils
      # sequence_class.send(:item_extension,options)
    end

    def include_drip_item
      item_class=Dripi.configuration.item.constantize
      item_class.include Item,Utils
      # item_class.send(:item_extension,options)
    end

  end
end

ActiveRecord::Base.send :extend, Dripi::Initializers
