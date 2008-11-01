$:.unshift File.dirname(__FILE__)

require 'singleton'

module Ick
  
  class GuardWrapper < IdentityWrapper
    def initialize(value, default, proc)
      @proc = proc
      @default = default
      super(value)
    end
    def __rewrap__(new_value)
      self.__class.new(new_value, @default, @proc) #contagious
    end
    def __invoke__(sym, *args, &block)
      @proc.call(@value, sym) ? super : @default
    end
  end
  
  class Guard < Wrap
    include Singleton
    
    def self.guard_with(&proc)
      @guard_proc = proc
    end
    
    def self.guard
      @guard_proc
    end
    
    def invoke(value, &proc)
      invoke_wrapped(value, GuardWrapper, nil, self.class.guard, &proc)
    end
    
  end
  
  class Maybe < Guard
    guard_with { |value, sym| value.nil? == false }
    evaluates_in_calling_environment and returns_result
  end
  
  class Try < Guard
    guard_with { |value, sym| value.respond_to?(sym) == true }
    evaluates_in_calling_environment and returns_result
  end
  
  class Please < Ick::Guard
    guard_with { |value, sym| value.respond_to?(sym) == true } # defines your guard condition
    evaluates_in_value_environment and returns_result          # defines its behaviour
  end

end