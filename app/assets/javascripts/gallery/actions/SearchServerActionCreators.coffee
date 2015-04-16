ActionTypes = HyperCheeseConstants.ActionTypes

@SearchServerActionCreators =
  receiveSearch: (resultCount, items, position) ->
    HyperCheeseDispatcher.handleServerAction
      type: ActionTypes.REQUEST_SEARCH_SUCCESS
      resultCount: resultCount
      items: items
      position: position


