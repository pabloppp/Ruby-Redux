require_relative '../redux'

describe Redux do
  before do
    # REDUCERS
    def counter(action, state = nil)
      state ||= 0
      case action[:type]
      when 'add'
        state + 1
      when 'substract'
        state - 1
      else
        state
      end
    end

    def trigger(action, state = nil)
      state ||= false
      case action[:type]
      when 'enable'
        true
      when 'disable'
        false
      else
        state
      end
    end

    # ACTIONS
    def add_one
      { type: 'add' }
    end

    def substract_one
      { type: 'substract' }
    end

    def switch_trigger(state)
      { type: state ? 'enable' : 'disable' }
    end

    def thunked_action
      lambda do |dispatch|
        Thread.start do
          sleep 0.05
          dispatch.call(add_one)
        end
      end
    end

    # MIDDLEWARES
    def all_actions_are_add(_)
      lambda do |dispatch|
        lambda do |action|
          action[:type] = 'add'
          dispatch.call(action)
        end
      end
    end

    def all_actions_are_substract(_)
      lambda do |dispatch|
        lambda do |action|
          action[:type] = 'substract'
          dispatch.call(action)
        end
      end
    end

    def thunk(_)
      lambda do |dispatch|
        lambda do |action|
          if action.respond_to? :call
            action.call(dispatch)
          else
            dispatch.call(action)
          end
        end
      end
    end
  end

  describe '#initialize' do
    it 'checks that the initial state is right' do
      store = Redux.create_store(method(:counter))
      expect(store.state).to eq(0)
    end
  end

  describe '#dispatch' do
    it 'checks that when an action is dispatched the state is update' do
      store = Redux.create_store(method(:counter))
      store.dispatch(type: 'add')
      expect(store.state).to eq(1)
      store.dispatch(type: 'substract')
      expect(store.state).to eq(0)
    end
  end

  describe '#subscribe' do
    it 'checks that one subscription gets called' do
      store = Redux.create_store(method(:counter))
      def listener(state)
        @counter = state
      end
      store.subscribe method :listener
      store.dispatch(type: 'add')
      store.dispatch(type: 'substract')
      store.dispatch(type: 'add')
      store.dispatch(type: 'add')
      expect(@counter).to eq(2)
    end
  end

  describe '#combine_reducers' do
    it 'checks combined reducers allow for the proper store' do
      combined_reducer = Redux.combine_reducers(
        method(:counter),
        method(:trigger)
      )
      store = Redux.create_store(combined_reducer)
      expect(store.state[:counter]).to eq(0)
      expect(store.state[:trigger]).to eq(false)
    end

    it 'checks that dispatched events modify correctly the state' do
      combined_reducer = Redux.combine_reducers(
        method(:counter),
        method(:trigger)
      )
      store = Redux.create_store(combined_reducer)
      store.dispatch(type: 'add')
      expect(store.state[:counter]).to eq(1)
      expect(store.state[:trigger]).to eq(false)
      store.dispatch(type: 'enable')
      expect(store.state[:counter]).to eq(1)
      expect(store.state[:trigger]).to eq(true)
    end
  end

  describe 'action creators' do
    it 'checks that action creators work exactly as sending barebone actions' do
      combined_reducer = Redux.combine_reducers(
        method(:counter),
        method(:trigger)
      )
      store = Redux.create_store(combined_reducer)
      store.dispatch(add_one)
      expect(store.state[:counter]).to eq(1)
      store.dispatch(substract_one)
      expect(store.state[:counter]).to eq(0)
      store.dispatch(switch_trigger(true))
      expect(store.state[:trigger]).to eq(true)
      store.dispatch(switch_trigger(false))
      expect(store.state[:trigger]).to eq(false)
    end
  end

  describe 'middleware' do
    it 'checks that middleware work' do
      combined_reducer = Redux.combine_reducers(
        method(:counter),
        method(:trigger)
      )
      store = Redux.create_store(
        combined_reducer,
        nil,
        Redux.apply_middlewares(
          method(:all_actions_are_add),
          method(:all_actions_are_substract)
        )
      )
      store.dispatch(switch_trigger(true))
      expect(store.state[:counter]).to eq(-1)
    end

    it 'check that thunk handles asynchronous actions' do
      @counter = 0
      def listener(state)
        @counter = state[:counter]
      end
      combined_reducer = Redux.combine_reducers(
        method(:counter)
      )
      store = Redux.create_store(
        combined_reducer,
        nil,
        Redux.apply_middlewares(method(:thunk))
      )
      store.subscribe method :listener
      store.dispatch(thunked_action)
      expect(store.state[:counter]).to eq(0)
      expect(@counter).to eq(0)
      sleep 0.1
      expect(store.state[:counter]).to eq(1)
      expect(@counter).to eq(1)
    end
  end
end
