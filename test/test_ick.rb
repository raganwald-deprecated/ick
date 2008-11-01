require File.dirname(__FILE__) + '/test_helper.rb'

class TestIck < Test::Unit::TestCase
  
  attr_accessor :value

  def setup
    @one = Box.new(1)
    self.value = 2
    @either_or = returning(Object.new) do |obj|
      def obj.does
        self
      end
      def obj.doesnt
        nil
      end
      def obj.inspect
        "either-or"
      end
      def obj.to_s
        "either-or"
      end
    end
  end
  
  def test_let
    assert_equal(1, let(@one) { |box| box.value } )
    assert_equal(2, let(@one) { value } )
    let(@one) { self.value = 3 }
    assert_equal(3, self.value)
    assert_equal(Box.new(1), @one)
  end
  
  def test_returning
    assert_equal(Box.new(1), returning(@one) { |box| box.value } )
    assert_equal(Box.new(1), returning(@one) { value } )
    returning(@one) { self.value = 3 }
    assert_equal(3, self.value)
    assert_equal(Box.new(1), @one)
  end
  
  def test_my
    assert_equal(1, my(@one) { |box| box.value } )
    assert_equal(1, my(@one) { value } )
    my(@one) { self.value = 3 }
    assert_equal(2, self.value)
    assert_equal(Box.new(3), @one)
  end
  
  def test_inside
    assert_equal(Box.new(1), inside(@one) { |box| box.value } )
    assert_equal(Box.new(1), inside(@one) { value } )
    inside(@one) { self.value = 3 }
    assert_equal(2, self.value)
    assert_equal(Box.new(3), @one)
  end
  
  def test_maybe
    assert_equal(@either_or, maybe(@either_or) do |e| e; end)
    assert_equal(@either_or, maybe(@either_or) do |obj|
      obj.does.does.does.does
    end)
    assert_nil(maybe(@either_or) do |obj|
      obj.doesnt.doesnt.doesnt.doesnt.doesnt
    end)
    assert_equal(@either_or, maybe(@either_or) do |outer|
      maybe(outer.does.does) do |inner|
        inner.does.does.does
      end
    end)
  end
  
  def test_try
    assert_equal(@either_or, try(@either_or) do |obj|
      obj.does.does.does.does
    end
    )
    assert_nil(try(@either_or) do |obj|
      obj.never.never.never.never
    end
    )
  end
  
  def test_invocation_super_sugar
     assert_nil(@either_or.maybe.doesnt)
     assert_nil(
      maybe(@either_or) do |obj|
        obj.__send__(:doesnt)
      end
     )
     assert_not_nil(
      maybe(@either_or) do |obj|
        obj.__send__(:does)
      end
     )
     assert_not_nil(@either_or.maybe.does)
     assert_nil(@either_or.try.never)
     assert_not_nil(@either_or.try.does)
  end
  
  def test_please
    assert_nil(
      please(:foo) { bar.blitz }
    )
  end
  
  def test_tee_basic
    box1 = Box.new(1)
    box2 = Box.new(2)
    assert_equal(box1.object_id, tee(box1,box2) { |box| box.value = 7 }.object_id)
    assert_equal(7, box1.value)
    assert_equal(7, box2.value)
  end
  
  def test_tee_semantics
    array_logger_one = []
    array_logger_two = []
    line_number = 0
    [array_logger_one, array_logger_two].map do |log|
      line_number += 1 
      log << "A#{line_number}"
      line_number += 1 
      log << "B#{line_number}"
    end
    assert_equal(%w(A1 B2), array_logger_one)
    assert_equal(%w(A3 B4), array_logger_two)
    array_logger_one = []
    array_logger_two = []
    line_number = 0
    tee(array_logger_one, array_logger_two) do |log|
      line_number += 1 
      log << "A#{line_number}"
      line_number += 1 
      log << "B#{line_number}"
    end
    assert_equal(%w(A1 B2), array_logger_one)
    assert_equal(%w(A1 B2), array_logger_two)
  end
  
  def test_fork_basic
    box1 = Box.new(1)
    box2 = Box.new(2)
    assert_equal(7, fork(box1,box2) { |box| box.value = 7 })
    assert_equal(7, box1.value)
    assert_equal(7, box2.value)
  end
  
end
