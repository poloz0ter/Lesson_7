module InstanceCounter
  
  def self.included(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end

  module ClassMethods
  attr_accessor :counter
    
    def instances
      self.counter ||= 0
    end
  end

  module InstanceMethods
    protected
    
    def register_instance
      self.class.counter ||= 0
      self.class.counter += 1
    end
  end
end
