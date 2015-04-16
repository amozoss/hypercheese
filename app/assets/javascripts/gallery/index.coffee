#= require react
#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require events
#= require underscore
#= require flux
#= require object-assign
#= require ./constants/HyperCheeseConstants
#= require ./dispatchers/HyperCheeseDispatcher
#= require ./actions/SearchServerActionCreators
#= require ./actions/SearchActionCreators
#= require ./utils/SearchAPI
#= require ./utils/StoreUtils
#= require ./stores/SearchStore
#= require ./components/app

React.render <GalleryApp/>, document.getElementById('content')
