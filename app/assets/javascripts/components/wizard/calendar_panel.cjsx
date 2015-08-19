React         = require 'react'
Panel         = require './panel'
TextInput     = require '../common/text_input'
Calendar      = require '../common/calendar'
CourseActions = require '../../actions/course_actions'
ServerActions = require '../../actions/server_actions'

CalendarPanel = React.createClass(
  displayName: 'CalendarPanel'
  updateDetails: (value_key, value) ->
    to_pass = @props.course
    to_pass[value_key] = value
    CourseActions.updateCourse to_pass, true
  render: ->
    timeline_start_props =
      minDate: moment(@props.course.start)
      maxDate: moment(@props.course.timeline_end).subtract(Math.max(1, @props.weeks), 'week')
    timeline_end_props =
      minDate: moment(@props.course.timeline_start).add(Math.max(1, @props.weeks), 'week')
      maxDate: moment(@props.course.end)

    raw_options = (
      <div>
        <Calendar course={@props.course} editable=true />
      </div>
    )

    <Panel {...@props} raw_options={raw_options} />

)

module.exports = CalendarPanel
