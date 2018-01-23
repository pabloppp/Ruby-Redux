module Redux
  def self.compose(*funcs)
    ->(arg) { arg } if funcs.length.zero?

    funcs[0] if funcs.length == 1

    lambda do |*intial_fn|
      chained_fn = intial_fn
      funcs.reverse.each do |func|
        chained_fn = func.call(*chained_fn)
      end
      chained_fn
    end
  end
end
