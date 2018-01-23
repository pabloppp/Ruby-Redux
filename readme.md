#### This is just an experiment, check out the [sample code](/sample) to see how it works by yourself...
You probably shouldn't be using this for any real thing, it's just illustrative, but suit yourself and copy/steal whatever you want!!!

## Ruby Redux
Yeah, weird combo, not trully usefull if you ask me but if you find a cool use for this, hooray!!

--------

So, what Redux components do I expose?
### Store
Redux proposes a 'single source of truth' approach, and that source of truth is called **store**.
In order for it to be really 'single' you should only be creating a single store and sharing it across your app, but y'know, if you want to have more than one **store** I'm not going to stop you...

Initialize it like this:
```
store = Redux.create_store(reducer, initial_state)
```
**initial_state** should be a Ruby hashmap/array/object containing the state in which your app should start, like let's say
```
initial_state = [
  { symbol: 'NVDA', price: 238 }
  { symbol: 'BTC', price: 11035 }
]
```
The state inside the store can be as complex as you want it to be, and is always inmutable, that means that every time you change the state, a new fresh copy of the state is created, but let's get to this later...

### Reducers
In Redux, reducer are the way to go when you need to modify the state (or like cool people like to call it, *reduce* the state).  
A reducer is basicaly a *dumb* function, that receives an action and a state and returns a new fresh state. It shoud NEVER have side effects because reasons!  
Usually a reducer is only responsible of handling a very specific piece of the state, so if your store keeps the state of the 
user and the state of the shopping cart, you should have two different reducers, one to handle all the actions on the user 
(i.e. update name, change profile picture, etc...) and another one for the cart (i.e. add/remove item to cart, checkout, etc...).  

You can then combine your reducers to create a SUPER REDUCER that you should plug into you store when you initialize it.
```
def my_reducer(action, state = nil)
  # do some stuff here with the state depending on the action
end

reducer = Redux.combine_reducers(
  method(:my_reducer)
)

store = Redux.create_store(reducer, initial_state)
```

### Other 'stuff'
This are not actually real components, just some cool tools to make your life easier.
The actions that you pass to the reducer can be anything, any kind of object 
(you might even want to create a class 'action' to represent them), but a cool trick is to use lambdas to avoid having 
to create the action each time you want to dispatch it.

For example let's say you have a reducer that removes an item from the list, and you code this inside of the action by having 2 parameters: 
`action = { type: 'ITEM_DELETE', index: 1 }`
But it is a pain in the ass to write this every time you want to delete an item (and very error prone), so let's instead use the power of lambdas!
```
@item_delete = lambda do |index|
  { type: 'ITEM_DELETE', index: index }
end
```
So, the next time we want to notify the store that an item was deleted we just need to do:
```
store.dispatch(@item_delete[1])
```

Finally because of the inmutable nature of the state, whenever you need to know it you can just read from it:
```
store.state[:user].name
```
And you can even keep a screenshot of a state that represent a specific point in the time of your app.

### That's all, I hope it's helpful to someone :+1:
