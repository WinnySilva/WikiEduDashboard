React = require 'react'
TrainingStore = require '../stores/training_store'
ServerActions = require '../../actions/server_actions'

getState = ->
  training_module: TrainingStore.getTrainingModule()

TrainingApp = React.createClass(
  mixins: [TrainingStore.mixin]
  getInitialState: ->
    getState()
  storeDidChange: ->
    @setState getState()
  componentWillMount: ->
    module_id = document.getElementById('react_root').dataset.moduleId
    ServerActions.fetchTrainingModule(module_id: module_id)
  render: ->
    slides = _.compact(@state.training_module.slides).map (slide) ->
      <li>
        <h3>{slide.title}</h3>
        <p>{slide.summary}</p>
      </li>

    <div>
      <h1>Table of Contents</h1>
      <ol>
      {slides}
      </ol>
    </div>
)

module.exports = TrainingApp
