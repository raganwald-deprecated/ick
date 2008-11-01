require File.dirname(__FILE__) + '/test_helper.rb'

class Symbol
  # Turns the symbol into a simple proc, which is especially useful for enumerations. 
  def to_proc
    Proc.new { |*args| args.shift.__send__(self, *args) }
  end
end

class Test180Seconds < Test::Unit::TestCase
  
  def test_blocks
arr = []

# let returns the value of the block and executes in the current environment
assert_equal(
  "3628800 ends with zero",
  let((1..10).inject(&:*)) { |num|
    arr << self.class
    num % 10 == 0 ? "#{num} ends with zero" : "#{num} does not end with zero"
  })
assert_equal([ self.class ], arr)

# returning returns the value of the expression and executes in the current environment
assert_equal(
  3628800,
  returning((1..10).inject(&:*)) { |num|
    arr << self.class
    num % 10 == 0 ? "#{num} ends with zero" : "#{num} does not end with zero"
  })
assert_equal([ self.class, self.class ], arr)

# my returns the value of the block and executes in the expression's environment
assert_equal(
  "3628800 ends with zero",
  my((1..10).inject(&:*)) { |num|
    arr << self.class
    num % 10 == 0 ? "#{num} ends with zero" : "#{num} does not end with zero"
  })
assert_equal([ self.class, self.class, Fixnum ], arr)

# inside returns the value of the expression and executes in the expression's environment
assert_equal(
  3628800,
  inside((1..10).inject(&:*)) { |num|
    arr << self.class
    num % 10 == 0 ? "#{num} ends with zero" : "#{num} does not end with zero"
  })
assert_equal([ self.class, self.class, Fixnum, Fixnum ], arr)
  end
  
  def test_guards
arr = []

# an object with two methods. #do returns itself, #do_not returns nil
yoda = returning(Object.new) do |obj|
  def obj.do
    self
  end
  def obj.do_not
    nil
  end
end

# maybe handles nils, even for methods nil has, but not missing methods
assert_equal(
  yoda, 
  maybe(yoda) { |obj| obj.do }
)
assert_nil(
  maybe(nil) { |obj| obj.do }
)
assert_nil(
  maybe(yoda) { |obj| obj.do_not.do }
)
assert_nil(
  maybe(nil) { |obj| obj.nil? }
)
assert_raise(NoMethodError) do
  maybe(yoda) { |obj| obj.fubar }
end

#try handles NoMethodErrors, without caring whether nil is involved
assert_equal(
  yoda, 
  try(yoda) { |obj| obj.do }
)
assert_nil(
  try(nil) { |obj| obj.do_not }
)
assert_not_nil(
  try(nil) { |obj| obj.nil? }
)
assert_nil(
  try(yoda) { |obj| obj.fubar }
)
    
  end
  
end