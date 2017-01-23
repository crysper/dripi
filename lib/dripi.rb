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
    raise Errors::RailsVersionError if !rails5?
    configure if configuration.nil?
    raise Errors::ModelNotFound, "Template" if !const_avai?(configuration.template)
    raise Errors::ModelNotFound, "Sequence" if !const_avai?(configuration.sequence)
    raise Errors::ModelNotFound, "Item"     if !const_avai?(configuration.item)
    raise Errors::ModelNotFound, "Job"      if !const_avai?(configuration.job)
  end

  class Configuration
    attr_accessor :template,:sequence,:item,:template_foreign_key,:job

    def initialize
      @template= 'Drip::Template'
      @sequence= 'Drip::Sequence'
      @item= 'Drip::Item'
      @job='DripSequenceJob'
      @template_foreign_key='drip_template_id'
    end
  end

  module DripableInstanceMethods
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

      include DripableInstanceMethods
      include_drip_template
      include_drip_sequence
      include_drip_item

      has_one :drip_sequence, as: :dripable, class_name: Dripi.configuration.sequence

    end

    def include_drip_template
      template_class=Dripi.configuration.template.constantize
      template_class.include Template,Utils
    end

    def include_drip_sequence
      sequence_class=Dripi.configuration.sequence.constantize
      sequence_class.include Sequence,Utils
    end

    def include_drip_item
      item_class=Dripi.configuration.item.constantize
      item_class.include Item,Utils
    end

  end
end

ActiveRecord::Base.send :extend, Dripi::Initializers
