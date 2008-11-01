module Ick
  
  module Syntax
  
      # I really want to express this somehow as pattern {
      #   lambda { _ }
      # }
      # and have it extract _ automatically, and somehow also 
      # use the exact same pattern to compose a sexp, much as
      # I used to have binary pattern expressions
      def sexp_for &proc
        sexp = proc.to_sexp
        return if sexp.length != 3
        return if sexp[0] != :proc
        return unless sexp[1].nil?
        sexp[2]
      end
      module_function :sexp_for
  
  end
  
end