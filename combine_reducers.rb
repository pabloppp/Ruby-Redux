module Redux
  def self.combine_reducers(*reducers)
    lambda do |action, state = nil|
      state ||= {}
      combined = {}
      reducers.each do |reducer|
        combined[reducer.name] = reducer.call(action, state[reducer.name])
      end
      combined
    end
  end
end
