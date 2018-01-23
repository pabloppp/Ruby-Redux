require_relative '../redux'

def todos(action, state = nil)
  state ||= []
  case action[:type]
  when 'ITEM_DELETE'
    cloned_state = state.clone
    cloned_state.delete_at(action[:index])
    cloned_state
  when 'ITEM_ADD'
    cloned_state = state.clone
    cloned_state << { title: action[:title], done: false }
    cloned_state
  when 'ITEM_DONE'
    cloned_state = state.clone
    cloned_state[action[:index]][:done] = true
    cloned_state
  else
    state
  end
end

@reducer = Redux.combine_reducers(
  method(:todos)
)
