require 'test/unit'
require File.dirname(__FILE__) + '/../lib/ick'
  
Ick.sugarize

class Box
  attr_accessor :value, :name
  
  def initialize(_value)
    self.value = _value
    self.name = self.to_s
  end
  
  def == (other)
    other.respond_to?(:value) && self.value == other.value
  end
  
  def to_s
    "Box(#{value})"
  end
  
  def inspect
    "Box(#{value})"
  end
  
end
