module Ick
  def self.sugarize
    [Let, Returning, My, Inside, Maybe, Try, Please, Tee, Fork, Syntax::Lets].each do |clazz|
      clazz.belongs_to Kernel
    end
  end
end