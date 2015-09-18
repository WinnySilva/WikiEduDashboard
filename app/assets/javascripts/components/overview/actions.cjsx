React           = require 'react'
ServerActions   = require '../../actions/server_actions'
CourseStore     = require '../../stores/course_store'
AssignCell      = require './assign_cell'
UserAssignmentStore = require '../../stores/user_assignment_store'

getState = (course_id) ->
  course: CourseStore.getCourse()
  assignments: UserAssignmentStore.getUserAssignments()

Actions = React.createClass(
  displayName: 'Actions'
  mixins: [CourseStore.mixin, UserAssignmentStore.mixin]
  storeDidChange: ->
    @setState getState()
  getInitialState: ->
    getState()
  join: ->
    passcode = prompt('Enter the passcode given to you by your instructor for this course')
    if passcode
      window.location = @state.course.enroll_url + passcode
  leave: ->
    if confirm 'Are you sure you want to leave this course?'
      user_obj = { user_id: @props.current_user.id, role: 0 }
      ServerActions.remove 'user', @state.course.slug, { user: user_obj }
  delete: ->
    entered_title = prompt "Are you sure you want to delete the course titled '#{@state.course.title}'? If so, type the title of the course to proceed."
    if entered_title == @state.course.title
      ServerActions.deleteCourse @state.course.slug
    else if entered_title?
      alert('"' + entered_title + '" is not the title of this course. The course has not been deleted.')
  update: ->
    ServerActions.manualUpdate @state.course.slug

  render: ->
    controls = []
    user = @props.current_user
    assignments = []
    if user.role? || user.admin
      # controls.push (
      #   <p key='update'><button onClick={@update} className='button'>Update course</button></p>
      # )
      if user.role == 0
        controls.push (
          <div className='sidebar__course-actions'>
            <p key='leave'><button onClick={@leave} className='button'>Leave course</button></p>
              <AssignCell
                assignments={@state.assignments}
                user={user}
                role=0
                course_id={@props.course.slug} />
          </div>
        )
      if (user.role == 1 || user.admin) && !@state.course.published
        controls.push (
          <p key='delete'><button className='button danger' onClick={@delete}>Delete course</button></p>
        )
    else
      controls.push (
        <p key='join'>
          <button onClick={@join} className='button'>Join course</button>
        </p>
      )

    controls.push (
      <p key='none'>No available actions</p>
    ) if controls.length == 0


    <div className='module'>
      <div className="section-header">
        <h3>Actions</h3>
      </div>
      <div className='module__data'>
        {controls}
      </div>
    </div>
)

module.exports = Actions
