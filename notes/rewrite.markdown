rewrite
---

working our way up to a language for specifying rewrites. For now, want to specify andand by example

	rewrite do
		$1.andand.$2 -> lambda { |_| _.$2 unless _.nil? }.call($1)
	end

This actually doesn't need any special delayed evaluation.`_` does need rewriting in the following case:

	rewrite do
		$1.andand.$2($3 >> $4) -> lambda { |_| _.$2($3 >> $4) unless _.nil? }.call($1)
	end
	
Because $3 and $4 may contain conflicting references.

	rewrite do
		$1.andand.$2($3 >> $4) { $5 } -> lambda { |_| _.$2($3 >> $4)  { $5 } unless _.nil? }.call($1)
	end

This is especially challenging.

A consideration: In addition to specifying andand, we want to specify a rule or rules that allow us to write call by name functions.