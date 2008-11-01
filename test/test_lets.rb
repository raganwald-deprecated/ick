require File.dirname(__FILE__) + '/test_helper.rb'

class TestLets < Test::Unit::TestCase
  
  def test_empty_body
    assert_nil lets(:foo => 'bar') { }
  end
  
  def test_one_parameter
    assert_equal('expected', lets(:foo => 'expected') { foo }) 
  end
  
  def test_two_parameters
    assert_equal(3, lets(:one => 1, :two => 2) { one + two })
  end
  
  def test_sequence
    foo = 0
    assert_equal(2, lets(:foo => 1, :bar => foo + 1) { foo + bar })
  end
  
  def test_a_few_truths_about_lambdas_and_bindings
    assert_raise(NameError) do
      lambda do
        foo1 = :bar
      end.call
      foo1
    end
    
    assert_raise(NameError) do
      lambda do |foo2|
        foo2
      end.call(:bar)
      foo2
    end
    
    instance_eval do
      foo4 = :unshadowed
      lambda do
        foo4 = :shadowed
        assert_equal(:shadowed, foo4)
      end.call
      assert_equal(:shadowed, foo4)
    end
    
    instance_eval do
      foo3 = :unshadowed
      lambda do |foo3|
        foo3
      end.call(:shadowed_which_will_be_fixed_in_ruby_one_point_nine)
      assert_equal(:shadowed_which_will_be_fixed_in_ruby_one_point_nine, foo3)
    end
    
  end
  
end