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
  def self.obj_to_s(obj)
    return nil if obj.nil?
    {class_name: obj.class.name,id: obj.id}
  end

  def self.s_to_obj(obj_s)
    return nil if obj_s.nil?
    obj_s[:class_name].constantize.find_by_id(obj_s[:id])
  end

  def self.oh_to_s(oh)
    return nil if oh.nil?
    oh.transform_values{|obj| obj.respond_to?(:id) ? obj_to_s(obj) : obj }
  end


  def self.s_to_oh(oh_s)
    return nil if oh_s.nil?
    oh_s.transform_values{|obj_s| (obj[:id] && obj[:class_name]) ? s_to_obj(obj_s) : obj_s}
  end
end
