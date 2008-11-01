module Ick
  
  class Wrapper
    
    alias  :__respond_to? :respond_to?
    alias :__instance_eval :instance_eval 
    alias :__class :class 
    alias :__inspect :inspect 
    instance_methods.reject { |m| m =~ /^__/ }.each { |m| undef_method m }
    alias :instance_eval :__instance_eval 
    
    def initialize(value, *additional_attributes)
      @value = value
    end
    
    def __value__
      @value
    end
    def __invocation__
      @invocation
    end
    def __rewrap__(value)
      raise 'implemented by subclass'
    end
    def __invoke__(sym, *args, &block)
      raise 'implemented by subclass'
    end
    def method_missing(sym, *args, &block)
      __rewrap__(__invoke__(sym, *args, &block))
    end
    def respond_to?(sym)
      @value.respond_to?(sym) || self.__respond_to?(sym)
    end
    
    def self.is_contagious
      define_method(:__rewrap__) { |value|
        self.__class.new(value) 
      }
    end
    
    def self.is_not_contagious
      define_method(:__rewrap__) { |value| value }
    end
    
  end
  
  class IdentityWrapper < Wrapper
    
    def __invoke__(sym, *args, &block)
      @value.__send__(sym, *args, &block)
    end
    
  end
  
  class ArrayWrapper < Wrapper
    
    def __invoke__(sym, *args, &block)
      @value.map { |_| _.__send__(sym, *args, &block) }
    end
    
    is_contagious
    
  end
  
  class Wrap < Base
    
    def wrap(value, wrapper_class, *additional_arguments)
      wrapper_class.new(value, *additional_arguments)
    end
    
    def unwrap(wrapped, wrapper_class)
      wrapped.respond_to?(:__value__) ? wrapped.__value__ : wrapped
    end
    
    def invoke_wrapped(value, wrapper_class, *additional_arguments, &proc)
      wrapped_value = wrap(value, wrapper_class, *additional_arguments)
      wrapped_result = evaluate(wrapped_value, proc)
      returns(unwrap(wrapped_value, wrapper_class), unwrap(wrapped_result, wrapper_class))
    end
    
    def invoke
      raise 'subclass should override and invoke invoke_wrapped'
    end
    
  end
  
end