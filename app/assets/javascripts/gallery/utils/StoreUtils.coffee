CHANGE_EVENT = 'change'

@StoreUtils =
  createStore: (spec) ->
    store = objectAssign({
      emitChange: () ->
        @emit(CHANGE_EVENT)

      addChangeListener: (callback) ->
        @on(CHANGE_EVENT, callback)

      removeChangeListener: (callback) ->
        @removeListener(CHANGE_EVENT, callback)
    }, spec, EventEmitter.prototype)

    _.each store, (val, key) ->
      if _.isFunction val
        store[key] = store[key].bind(store)

    store.setMaxListeners(0)
    return store


