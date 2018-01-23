require_relative '../redux'
require_relative 'reducers'
require_relative 'actions'

initial_state = [
  { title: 'buy potatoes', done: false },
  { title: 'get a haircut', done: false },
  { title: 'pay the rent', done: false }
]

store = Redux.create_store(@reducer, initial_state)

loop do
  system 'clear'
  puts 'Ruby Redux ToDo app'
  store.state[:todos].select { |i| !i[:done] }.each do |item|
    puts "##{store.state[:todos].index(item)} - #{item[:title]}"
  end
  if store.state[:todos].any? { |i| i[:done] }
    puts "\nDone"
    store.state[:todos].select { |i| i[:done] }.each do |item|
      puts "\e[1m##{store.state[:todos].index(item)} - #{item[:title]}\e[22m"
    end
  end
  puts "\nActions -> 1: delete - 2: add - 3: done"

  input = $stdin.gets.chomp
  case input
  when '1', 'delete'
    puts 'What element do you want to delete? (index)'
    store.dispatch(@item_delete[$stdin.gets.to_i])
  when '2', 'add'
    puts 'Write the text of the todo: '
    store.dispatch(@item_add[$stdin.gets.chomp])
  when '3', 'done'
    puts 'What element do you want to mark as done? (index)'
    store.dispatch(@item_done[$stdin.gets.to_i])
  end
end
