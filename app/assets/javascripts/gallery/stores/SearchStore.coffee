ActionTypes = HyperCheeseConstants.ActionTypes
_items = {}
_resultCount = 0
_isLoading = false

@SearchStore = StoreUtils.createStore
  getItems: () ->
    return _items

  getResultCount: () ->
    return _resultCount

  injectItems: (items, pos) ->
    newItems = @shallowCopyItems()
    console.log 'searchstore', newItems

    i = 0
    while i < items.length
      items[i].position = pos + i
      newItems[pos + i] = items[i]
      i++

    console.log newItems
    _items = newItems

  shallowCopyItems: ->
    $.extend {}, _items

  updateItem: (item) ->
    newItems = @shallowCopyItems()
    newItems[item.position] = item
    _items = newItems

@SearchStore.dispatcherToken = HyperCheeseDispatcher.register (payload) ->
  switch payload.action.type 
    when ActionTypes.REQUEST_SEARCH
      _isLoading = true
      SearchStore.emitChange()

    when ActionTypes.REQUEST_SEARCH_SUCCESS
      _resultCount = payload.action.resultCount
      _isLoading = false

      items = payload.action.items
      position = payload.action.position
      #_items = items
      SearchStore.injectItems(items, position)
      SearchStore.emitChange()

    when ActionTypes.REQUEST_SEARCH_COMPLETE
      _isLoading = false

    when ActionTypes.UPDATE_ITEM
      SearchStore.updateItem(payload.action.item)
      SearchStore.emitChange()

