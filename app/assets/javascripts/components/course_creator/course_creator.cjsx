React         = require 'react'
Router        = require 'react-router'
Link          = Router.Link

CourseStore       = require '../../stores/course_store'
CourseActions     = require '../../actions/course_actions'
ValidationStore   = require '../../stores/validation_store'
ValidationActions = require '../../actions/validation_actions'
ServerActions     = require '../../actions/server_actions'

Modal         = require '../common/modal'
TextInput     = require '../common/text_input'
TextAreaInput = require '../common/text_area_input'

getState = ->
  course: _.extend CourseStore.getCourse(), user_id: $('main').data('user-id')
  error_message: ValidationStore.firstMessage()

CourseCreator = React.createClass(
  displayName: 'CourseCreator'
  mixins: [CourseStore.mixin, ValidationStore.mixin]
  contextTypes:
    router: React.PropTypes.func.isRequired
  storeDidChange: ->
    @setState getState()
    @state.tempCourseId = @generateTempId()

    @handleCourse()
  componentWillMount: ->
    CourseActions.addCourse()
  generateTempId: ->
    title = if @state.course.title? then @slugify @state.course.title else ''
    school = if @state.course.school? then @slugify @state.course.school else ''
    term = if @state.course.term? then @slugify @state.course.term else ''
    return "#{school}/#{title}_(#{term})"
  slugify: (text) ->
    return text.replace " ", "_"
  saveCourse: ->
    if ValidationStore.isValid()
      @setState isSubmitting: true
      ValidationActions.setInvalid 'exists', 'This course is being checked for uniqueness', true
      ServerActions.checkCourse('exists', @generateTempId())
  handleCourse: ->
    return unless @state.isSubmitting
    if ValidationStore.isValid()
      if @state.course.slug?
        # This has to be a window.location set due to our limited ReactJS scope
        window.location = '/courses/' + @state.course.slug + '/timeline/wizard'
      else
        ServerActions.saveCourse $.extend(true, {}, { course: @state.course })
    else if !ValidationStore.getValidation('exists').valid
      @setState isSubmitting: false
  updateCourse: (value_key, value) ->
    to_pass = $.extend(true, {}, @state.course)
    to_pass[value_key] = value
    CourseActions.updateCourse to_pass
    if value_key in ['title', 'school', 'term']
      ValidationActions.setValid 'exists'
  getInitialState: ->
    $.extend(true, { tempCourseId: '', isSubmitting: false}, getState())
  render: ->
    form_style = { }
    form_style.opacity = 0.5 if @state.isSubmitting is true
    form_style.pointerEvents = 'none' if @state.isSubmitting is true

    <Modal>
      <div className="wizard__panel active" style={form_style}>
        <h3>{I18n.t('course_creator.create_new')}</h3>
        <p>{I18n.t('course_creator.intro')}</p>
        <div className='wizard__form'>
          <div className='column'>

            <TextInput
              id='course_title'
              onChange={@updateCourse}
              value={@state.course.title}
              value_key='title'
              required=true
              validation={/^[\w\-\s\,\']+$/}
              editable=true
              label='Course title'
              placeholder='Title'
            />
            <TextInput
              id='instructor_name'
              onChange={@updateCourse}
              value={@state.course.instructor_name}
              value_key='instructor_name'
              required=true
              editable=true
              label='Instructor Name'
              placeholder='Name'
            />
            <TextInput
              id='instructor_email'
              onChange={@updateCourse}
              value={@state.course.instructor_email}
              value_key='instructor_email'
              required=true
              editable=true
              label='Instructor Email'
              placeholder='hello@example.edu'
            />
            <TextInput
              id='course_school'
              onChange={@updateCourse}
              value={@state.course.school}
              value_key='school'
              required=true
              validation={/^[\w\-\s\,\']+$/}
              editable=true
              label='Course school'
              placeholder='School'
            />
            <TextInput
              id='course_term'
              onChange={@updateCourse}
              value={@state.course.term}
              value_key='term'
              required=true
              validation={/^[\w\-\s\,\']+$/}
              editable=true
              label='Course term'
              placeholder='Term'
            />
            <TextInput
              id='course_subject'
              onChange={@updateCourse}
              value={@state.course.subject}
              value_key='subject'
              editable=true
              label='Course subject'
              placeholder='Subject'
            />
            <TextInput
              id='course_expected_students'
              onChange={@updateCourse}
              value={@state.course.expected_students}
              value_key='expected_students'
              editable=true
              type='number'
              label='Expected number of students'
              placeholder='Expected number of students'
            />
          </div>
          <div className='column'>
            <TextAreaInput
              id='course_description'
              onChange={@updateCourse}
              value={@state.course.description}
              value_key='description'
              editable=true
              label='Course description'
              autoExpand=false
            />
          </div>
        </div>
        <div className='wizard__panel__controls'>
          <div className='left'><p>{@state.tempCourseId}</p></div>
          <div className='right'>
            <div><p className='red'>{@state.error_message}</p></div>
            <Link className="button" to="/" id='course_cancel'>Cancel</Link>
            <button onClick={@saveCourse} className='dark button'>Create my Course!</button>
          </div>
        </div>
      </div>
    </Modal>
)

module.exports = CourseCreator
