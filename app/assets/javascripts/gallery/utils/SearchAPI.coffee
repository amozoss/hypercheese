@SearchAPI = 
  executeSearch: (position, searchQuery) ->
    limit = 20
    if @searching?
      # ignore duplicate requests
      return unless @searching + limit < position || position + limit < @searching
      @searchRequest.abort()

    @searching = position

    console.log position
    console.log searchQuery
    @searchRequest = $.ajax
      url: "/items"
      dataType: "json"
      data:
        limit: limit
        offset: position
        query: searchQuery
      success: (res) =>
        @searching = null
        SearchServerActionCreators.receiveSearch(res.meta.total, res.items, position)

      complete: =>
        @searching = null

