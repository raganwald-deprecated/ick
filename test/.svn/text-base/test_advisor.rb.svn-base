require File.dirname(__FILE__) + '/test_helper.rb'

class NoAdvice < Ick::Advisor
end

class NameUpdator < Ick::Advisor
  around :only => :value= do |callback, receiver, sym, *args|
    callback.call()
    receiver.name = receiver.to_s
  end
end

class NameUpdatorByMethod < Ick::Advisor
  around :update, :only => :value=
  
  def self.update(callback, receiver, sym, *args)
    callback.call()
    receiver.name = receiver.to_s
  end
end

class DoublePlusOne < Ick::Advisor
  around :only => :value= do |callback, receiver, sym, *args|
    callback.call()
    receiver.name = receiver.to_s
  end
end

class TestAdvisor < Test::Unit::TestCase
  
  def setup
    @box1 = Box.new(1)
    @box_one = Box.new(1)
  end
  
  def test_no_advice
    nullo = NoAdvice.new(@box1)
    nullo.value = 2
    assert_equal(2, @box1.value)
  end
  
  def test_simple_around_advice
    old_string = @box1.name
    @box1.value = 2
    assert_equal(2, @box1.value)
    assert_equal(old_string, @box1.name) # The name has not changed
    assert_not_equal(old_string, @box1.to_s) # but the string has
    updating = NameUpdator.new(@box_one)
    updating.value = 2
    assert_equal(updating.to_s, updating.name) # updated the name
  end
  
  def test_simple_by_method
    updating = NameUpdatorByMethod.new(@box_one)
    updating.value = 2
    assert_equal(updating.to_s, updating.name) # updated the name
  end
  
  def test_simple_around_advice
    old_string = @box1.name
    @box1.value = 2
    assert_equal(2, @box1.value)
    assert_equal(old_string, @box1.name) # The name has not changed
    assert_not_equal(old_string, @box1.to_s) # but the string has
    updating = NameUpdator.new(@box_one)
    updating.value = 2
    assert_equal(updating.to_s, updating.name) # updated the name
  end
  
end