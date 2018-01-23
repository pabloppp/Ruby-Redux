module Redux
  def self.create_store(reducer, initial_state = nil, middleware = nil)
    if middleware.nil?
      Store.new(reducer, initial_state)
    else
      middleware.call(method(:create_store)).call(reducer, initial_state)
    end
  end

  class Store
    def initialize(reducer, initial_state = nil)
      @reducer = reducer
      @state = @reducer.call({ type: nil }, initial_state)
      @listeners = []
    end

    def dispatch(action)
      @state = @reducer.call(action, state)
      @listeners.each { |listener| listener.call(state) }
    end

    def subscribe(listener)
      @listeners.push(listener)
    end

    def self.create_store(reducer, initial_state = nil, middleware = nil)
      if middleware.nil?
        new(reducer, initial_state)
      else
        middleware.call(method(:create_store)).call(reducer, initial_state)
      end
    end

    attr_reader :state
  end
end
