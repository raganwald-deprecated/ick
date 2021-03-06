module Ick
  class Advisor < Wrapper
    
    def self.around *args, &proc # { |callback, receiver, sym, *args| ... }
      target, conditions = self.extract_parameters(args)
      old_arounds = self.around_chain 
      if target.kind_of?(Symbol)
        proc = lambda { |callback, receiver, sym, *args|
          self.send(target, callback, receiver, sym, *args, &proc)
        }
      elsif target.kind_of?(Class)
        proc = lambda { |callback, receiver, sym, *args|
          target.filter(receiver, sym, *args, &proc)
        }
      end
      self.around_chain = 
        if conditions[:only]
          lambda { |callback, receiver, sym, *args|
            new_callback = lambda { old_arounds.call(callback, receiver, sym, *args) }
            Array(conditions[:only]).include?(sym) ? proc.call(callback, receiver, sym, *args) : callback.call()
          }
        elsif conditions[:except]
          lambda { |callback, receiver, sym, *args|
            new_callback = lambda { old_arounds.call(callback, receiver, sym, *args) }
            Array(conditions[:except]).include?(sym) ? new_callback.call() : proc.call(new_callback, receiver, sym, *args)
          }
        else
          lambda { |callback, receiver, sym, *args|
            new_callback = lambda { old_arounds.call(callback, receiver, sym, *args) }
            proc.call(new_callback, receiver, sym, *args)
          }
        end
    end
    
    def self.before *args, &proc # { |receiver, sym, *args| ... }
      self.around(*args, &(lambda { |callback, receiver, sym, *args|  
        proc.call(receiver, sym, *args)
        callback.call()
      }))
    end
    
    def self.after *args, &proc # { |receiver, sym, *args| ... }
      self.around(*args, &(lambda { |callback, receiver, sym, *args|  
        callback.call()
        proc.call(receiver, sym, *args)
      }))
    end
    
    def __invoke__(sym, *args, &block)
      self.__class.around_chain.call(
        lambda { @value.__send__(sym, *args, &block) },
        @value,
        sym,
        *args
      )
    end
    
    is_not_contagious
    
    private
    
    def self.around_chain
      @around_chain || lambda { |callback, receiver, sym, *args|
      callback.call()
    }
    end
    
    def self.around_chain=(chain)
      @around_chain = chain
    end
    
    def self.extract_parameters arr
      if arr.empty?
        []
      elsif arr.size == 2
        arr
      elsif arr.size > 2
        [arr[0..-2], arr[-1]]
      elsif arr.first.kind_of?(Class) or arr.first.kind_of?(Symbol)
        [arr[0], {}]
      elsif arr.first.respond_to?(:[])
        [nil, arr.first]
      else
        raise "Argument problem with #{arr}"
      end
    end
    
  end
  
end