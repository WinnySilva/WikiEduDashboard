React         = require 'react/addons'
LookupStore   = require '../../stores/lookup_store'

LookupWrapper = (Component) ->
  getState = (model, exclude) ->
    models: _.difference(LookupStore.getLookups(model), exclude)
    submitting: false
  React.createClass(
    displayname: 'LookupWrapper'
    mixins: [LookupStore.mixin]
    getInitialState: ->
      getState(@props.model, @props.exclude)
    componentWillReceiveProps: (newProps) ->
      @setState getState(newProps.model, newProps.exclude)
    storeDidChange: ->
      @setState getState(@props.model, @props.exclude)
    getValue: ->
      @refs.entry.getValue()
    clear: ->
      @refs.entry.clear()
    render: ->
      <Component {...@props} {...@state} ref='entry' />
  )

module.exports = LookupWrapper
