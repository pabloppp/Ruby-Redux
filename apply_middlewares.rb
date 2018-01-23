require_relative './compose'

module Redux
  def self.apply_middlewares(*middlewares)
    lambda do |create_store|
      lambda do |reducer, initial_state = nil, enhancer = nil|
        @store = create_store.call(reducer, initial_state, enhancer)
        @dispatch = @store.method(:dispatch)
        chain = middlewares.map { |middleware| middleware.call(middleware_api) }
        update_dispatch Redux.compose(*chain).call(@store.method(:dispatch))
        @store
      end
    end
  end

  def self.update_dispatch(dispatch)
    @store.define_singleton_method(:dispatch) do |action|
      dispatch.call(action)
    end
  end

  def self.middleware_api
    {
      state: @store.state,
      dispatch: lambda do |action|
        @dispatch.call(action)
      end
    }
  end
end
