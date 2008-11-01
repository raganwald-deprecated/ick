$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'parse_tree'
require 'sexp_processor'
require File.dirname(__FILE__) + '/rewritten'

module Ick
  
  module Syntax
  
    class Lets < Rewritten
    
      def rewrite_sexp(sexp, names_to_values_a)
        names_to_values = names_to_values_a.first
        mono_parameter = Syntax.gensym()
        # the next four assignments are exactly why we want #lets:
        sorted_symbols = (names_to_values || {}).keys.map { |name| name.to_s }.sort.map { |name| name.to_sym }
        parameters = if sorted_symbols.size == 1
          s(:dasgn_curr, sorted_symbols.first)
        else
          s(:masgn, s(:array, *sorted_symbols.map { |sym| s(:dasgn_curr, sym) }) )
        end
        values = s(:array,
          *sorted_symbols.map { |sym|
            s(:call, 
              s(:call, s(:dvar, mono_parameter), :first), 
              :[], 
              s(:array, s(:lit, sym))
            )
          }
        )
        body = sexp.last
      
        s(:defn, :__anonymous__, 
          s(:bmethod, 
            s(:dasgn_curr, mono_parameter), 
            s(:call, 
              s(:iter, 
                s(:fcall, :lambda), 
                parameters,
                body
              ), 
              :call, 
              values
            )
          )
        )

      end
    
      evaluates_in_calling_environment and returns_result
    
    end
  
  end
  
end