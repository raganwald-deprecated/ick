$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'ruby2ruby'
require 'parse_tree'

module Ick
  
  module Syntax
      
    def self.gensym
      :"__#{Time.now.to_i}#{rand(100000)}__"
    end
  
    class Rewritten < Base
    
      def rewrite_sexp(sexp, *values)
        raise 'implemented by subclass or by calling meta-method!'
      end
    
      # gnarly text munging copied & pasted from http://pastie.caboo.se/137859
      # which was itself copied from ruby2ruby source for Proc#to_ruby
      def generate_ruby sexp
        ruby = Ruby2Ruby.new.process(sexp)
        ruby.sub!(/\A(def \S+)\(([^\)]*)\)/, '\1 |\2|')     # move args
        ruby.sub!(/\Adef[^\n\|]+/, 'proc { ')               # strip def name
        ruby.sub!(/end\Z/, '}')                             # strip end
        ruby.gsub!(/\s+$/, '')                              # trailing WS bugs me
        ruby
      end
    
      # TODO: refactor this so that we can *chain* things in invoke to get away from overriding
    
      def invoke(*values, &proc)
        if values.first.is_a? Binding
          bind = values.shift
        else
          bind = Kernel.binding()
        end
        rewritten_sexp = rewrite_sexp(proc.to_sexp, values)
        ruby = generate_ruby(rewritten_sexp)
        p ruby
        rewritten_proc = eval(ruby, bind)
        super(values, &rewritten_proc)
      end
    
      def to_ruby(*values, &proc)
        rewritten_sexp = rewrite_sexp(proc.to_sexp, values)
        generate_ruby(rewritten_sexp)
      end
      
      def self.to_ruby(*values, &proc)
        instance.to_ruby(values, &proc)
      end
      
    end
  
  end
  
end