React         = require 'react'
DayPicker     = require 'react-day-picker'
WeekdayPicker = require 'react-weekday-picker'

CourseActions = require '../../actions/course_actions'

Calendar = React.createClass(
  displayName: 'Calendar'
  selectDay: (e, day) ->
    return unless @inrange(day)
    to_pass = @props.course
    if !to_pass['day_exceptions']?
      to_pass['day_exceptions'] = ''
      exceptions = []
    else
      exceptions = to_pass['day_exceptions'].split(',')
    formatted = moment(day).format('YYYYMMDD')
    if formatted in exceptions
      exceptions.splice(exceptions.indexOf(formatted), 1)
    else
      exceptions.push formatted
    to_pass['day_exceptions'] = exceptions.join(',')
    CourseActions.updateCourse to_pass, (@props.save? && @props.save)
  selectWeekday: (e, weekday) ->
    to_pass = @props.course
    if !to_pass['weekdays']?
      to_pass['weekdays'] = ''
      weekdays = []
    else
      weekdays = to_pass['weekdays'].split('')
    weekdays[weekday] = if weekdays[weekday] == '1' then '0' else '1'
    to_pass['weekdays'] = weekdays.join('')
    CourseActions.updateCourse to_pass, (@props.save? && @props.save)
  inrange: (day) ->
    return false unless @props.course.start?
    start = moment(@props.course.start, 'YYYY-MM-DD').subtract(1, 'day').format('YYYY-MM-DD')
    end = moment(@props.course.end, 'YYYY-MM-DD').add(1, 'day').format('YYYY-MM-DD')
    moment(day).isBetween(start, end)
  render: ->
    modifiers = {
      'outrange': (day) =>
        !@inrange(day)
      'selected': (day) =>
        if @props.course.weekdays? && @props.course.weekdays.charAt(day) == '1'
          return true
        else if day < 8
          return false
        formatted = moment(day).format('YYYYMMDD')
        inrange = @inrange(day)
        exception = false
        weekday = false
        if @props.course.day_exceptions?
          exception = formatted in @props.course.day_exceptions.split(',')
        if @props.course.weekdays
          weekday = @props.course.weekdays.charAt(moment(day).format('e')) == '1'
        inrange && ((weekday && !exception) || (!weekday && exception))
      'highlighted': (day) =>
        return false unless day > 7
        @inrange(day)
      'bordered': (day) =>
        return false unless day > 7
        return false unless @props.course.day_exceptions? && @props.course.weekdays
        formatted = moment(day).format('YYYYMMDD')
        inrange = @inrange(day)
        exception = formatted in @props.course.day_exceptions.split(',')
        weekday = @props.course.weekdays.charAt(moment(day).format('e')) == '1'
        inrange && exception && weekday
    }
    help_text = (
      <p><strong>2. Click dates to add them to or remove them from the schedule.</strong></p>
    ) if @props.editable
    editing_calendar = (
      <div className='editing-calendar'>
        <h3>Key</h3>
        <ul className='editing-calendar__key-ul'>
          <li>
            <strong>Day out of range of class dates</strong>
            <div className='DayPicker-Day DayPicker-Day--outrange'>6</div>
          </li>
          <li>
            <strong>No Class Scheduled</strong>
            <div className='DayPicker-Day DayPicker-Day--highlighted'>6</div>
          </li>
          <li>
            <strong>Class Day</strong>
            <div className='DayPicker-Day DayPicker-Day--highlighted DayPicker-Day--selected'>6</div>
          </li>
          <li>
            <strong>Class Holiday</strong>
            <div className='DayPicker-Day DayPicker-Day--highlighted DayPicker-Day--bordered'>6</div>
          </li>
        </ul>
      </div>
    ) if @props.editable

    <div>
      <WeekdayPicker
        modifiers={modifiers}
        onWeekdayClick={if @props.editable then @selectWeekday else null}
      />
      {help_text}
      <DayPicker
        modifiers={modifiers}
        onDayClick={if @props.editable then @selectDay else null}
        onWeekdayClick={if @props.editable then @selectWeekday else null}
        initialMonth={moment.max(moment(@props.course.start), moment()).toDate()}
      />
      {editing_calendar}
    </div>
)

module.exports = Calendar
