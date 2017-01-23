module Dripi::Utils
  module ClassUtils
    def required_methods(*list)
      list.each{|e|
        raise ActiveModel::MissingAttributeError, "Missing required instance method or attribute '#{e.to_s}'. Required are: #{list.join(',')}"  if !self.new.respond_to?(e)
      }
    end
  end
  def self.included(base)
     base.extend ClassUtils
  end
end

module Dripi
  module Errors
    class RailsVersionError < StandardError; def initialize(msg='Works only on Rails 5');super(msg); end;end
        class ModelNotFound < StandardError; def initialize(msg);super(msg+' Model not initialized'); end;end    
  end

  class << self
    def rails5?
         Rails.version.start_with? '5'
    end

    def obj_(oh)
      return nil if oh.nil?
      return o_(oh) if !oh.is_a?(Hash)
      oh.transform_values{|o| obj_(o)}
    end

    def _obj(oh)
      return nil if oh.nil?
      return _o(oh) if !oh.is_a?(Hash) || (oh.keys.sort == [:class_name,:id])
      oh.transform_values{|o| _obj(o)}
    end

    private
      def o_(oh)
        return nil if oh.nil?
        return oh if !oh.respond_to?(:id)
        {class_name: oh.class.name,id: oh.id}
      end

      def _o(oh)
        return nil if oh.nil?
        return oh if !oh[:id] || !oh[:class_name]
        oh[:class_name].constantize.find_by_id(oh[:id])
      end

  end
end
