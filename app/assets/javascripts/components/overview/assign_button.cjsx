React         = require 'react/addons'
Router        = require 'react-router'
Link          = Router.Link
Expandable    = require '../high_order/expandable'
Popover       = require '../common/popover'
Lookup        = require '../common/lookup'
ServerActions = require '../../actions/server_actions'
AssignmentActions = require '../../actions/assignment_actions'
AssignmentStore = require '../../stores/assignment_store'

urlToTitle = (article_url) ->
  article_url = article_url.trim()
  unless /http/.test(article_url)
    return article_url.replace(/_/g, ' ')

  url_parts = /\/wiki\/(.*)/.exec(article_url)
  return unescape(url_parts[1]).replace(/_/g, ' ') if url_parts.length > 1
  return null

AssignButton = React.createClass(
  displayname: 'AssignButton'
  getInitialState: ->
    send: false
  componentWillReceiveProps: (nProps) ->
    if @state.send
      console.log('ohai')
      @setState send: false
  stop: (e) ->
    e.stopPropagation()
  getKey: ->
    tag = if @props.role == 0 then 'assign_' else 'review_'
    tag + @props.user.id
  assign: (e) ->
    e.preventDefault()
    article_title = urlToTitle @refs.lookup.getValue()

    # Check if the assignment exists
    if AssignmentStore.getFiltered({
      article_title: article_title,
      user_id: @props.user.id,
      role: @props.role
    }).length != 0
      alert 'This assignment already exists!'
      return

    # Confirm
    return unless confirm I18n.t('assignments.confirm_addition', {
      title: article_title,
      username: @props.user.wiki_id
    })

    # Send
    if(article_title)
      AssignmentActions.addAssignment @props.course_id, @props.user.id, article_title, @props.role
      @setState send: true
      @refs.lookup.clear()
  unassign: (assignment) ->
    return unless confirm(I18n.t('assignments.confirm_deletion'))
    AssignmentActions.deleteAssignment assignment
    @setState send: true
  render: ->
    className = 'button border'
    className += ' dark' if @props.is_open

    if @props.assignments.length > 1
      raw_a = @props.assignments[0]
      show_button = <button className={className + ' plus'} onClick={@props.open}>+</button>
    else
      assign_text = 'Assign myself an article'
      review_text = 'Review an article'
      final_text = if @props.role == 0 then assign_text else review_text
      edit_button = (
        <button className={className} onClick={@props.open}>{final_text}</button>
      )
    assignments = @props.assignments.map (ass) =>
      remove_button = <button className='button border plus' onClick={@unassign.bind(@, ass)}>-</button>
      if ass.article_url?
        link = <a href={ass.article_url} target='_blank' className='inline'>{ass.article_title}</a>
      else
        link = <span>{ass.article_title}</span>
      <tr key={ass.id}>
        <td>{link}{remove_button}</td>
      </tr>
    if @props.assignments.length == 0
      assignments = <tr><td>No articles assigned</td></tr>

    edit_row = (
      <tr className='edit'>
        <td>
          <form onSubmit={@assign}>
            <Lookup model='article'
              placeholder='Article title'
              ref='lookup'
              onSubmit={@assign}
              disabled=true
            />
            <button className='button border' type="submit">Assign</button>
          </form>
        </td>
      </tr>
    )


    <div className='pop__container' onClick={@stop}>
      {show_button}
      {edit_button}
      <Popover
        is_open={@props.is_open}
        edit_row={edit_row}
        rows={assignments}
      />
    </div>
)

module.exports = Expandable(AssignButton)
