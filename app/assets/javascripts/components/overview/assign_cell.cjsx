React           = require 'react/addons'
Router          = require 'react-router'
Link            = Router.Link
AssignButton    = require './assign_button'
UIActions       = require '../../actions/ui_actions'

AssignCell = React.createClass(
  displayname: 'AssignCell'
  stop: (e) ->
    e.stopPropagation()
  open: (e) ->
    @refs.button.open(e)
  render: ->
    if @props.assignments.length > 0
      raw_a = @props.assignments[0]
      if @props.assignments.length > 1
        link = <span onClick={@open}>{@props.assignments.length + ' articles'}</span>
      else
        title_text = raw_a.article_title.trunc()
        if raw_a.article_url?
          link = (
            <a onClick={@stop} href={raw_a.article_url} target="_blank" className="inline">{title_text}</a>
          )
        else
          link = <span>{title_text}</span>

    <div>
      {link}
      <AssignButton
        user={@props.user}
        role={@props.role}
        assignments={@props.assignments}
        course_id={@props.course_id}
        ref='button' />
    </div>
)

module.exports = AssignCell
