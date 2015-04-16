ActionTypes = HyperCheeseConstants.ActionTypes

@SearchActionCreators = 
  executeSearch: (position) ->
    HyperCheeseDispatcher.handleViewAction 
      type: ActionTypes.REQUEST_SEARCH

    SearchAPI.executeSearch(position)

  updateItem: (item) ->
    HyperCheeseDispatcher.handleViewAction
      type: ActionTypes.UPDATE_ITEM
      item: item


