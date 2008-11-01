# Inspired by
# http://probablycorey.wordpress.com/2008/03/28/abusing-rubys-question-mark-methods/

module Ick

  class Bizarro
    
    def invoke(*values, &proc)
      invoke_wrapped(values, ArrayWrapper, nil, &proc)
    end
    
    def unwrap(wrapped, wrapper_class)
      wrapped.respond_to?(:__value__) ? wrapped.__value__.first : wrapped
    end
    
    def self.belongs_to clazz
      method_name = self.underscore(self.name.split('::')[-1])
      unless clazz.method_defined?(method_name)
        clazz.class_eval " 
          def #{method_name}(*values,&proc)
            values = [self] if values.empty?
            if block_given?
              #{self.name}.instance.invoke(*values, &proc)
            else
              Invoker.new(values, #{self.name})
            end
          end"
      end
    end
    
  end

  class Tee < Split
    evaluates_in_calling_environment and returns_value
  end

  class Fork < Split
    evaluates_in_calling_environment and returns_result
  end
  
end