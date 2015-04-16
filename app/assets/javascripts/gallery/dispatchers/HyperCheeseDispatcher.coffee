PayloadSources = HyperCheeseConstants.PayloadSources

@HyperCheeseDispatcher = objectAssign new Flux.Dispatcher(), {
  handleServerAction: (action) ->
    payload =
      source: PayloadSources.SERVER_ACTION
      action: action
    @dispatch payload

  handleViewAction: (action) ->
    payload =
      source: PayloadSources.VIEW_ACTION
      action: action
    @dispatch payload
}







