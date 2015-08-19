React         = require 'react'
Panel         = require './panel'
TextInput     = require '../common/text_input'
CourseActions = require '../../actions/course_actions'
ServerActions = require '../../actions/server_actions'

FormPanel = React.createClass(
  displayName: 'FormPanel'
  updateDetails: (value_key, value) ->
    to_pass = @props.course
    to_pass[value_key] = value
    CourseActions.updateCourse to_pass, true
  render: ->
    raw_options = (
      <div className='wizard__form course-dates'>
        <TextInput
          onChange={@updateDetails}
          value={@props.course.start}
          value_key='start'
          editable=true
          type='date'
          autoExpand=true
          label='Course Start'
        />
        <TextInput
          onChange={@updateDetails}
          value={@props.course.end}
          value_key='end'
          editable=true
          type='date'
          label='Course End'
          date_props={minDate: moment(@props.course.start).add(1, 'week')}
          enabled={@props.course.start?}
        />
      </div>
    )

    <Panel {...@props} raw_options={raw_options} />
)

module.exports = FormPanel
