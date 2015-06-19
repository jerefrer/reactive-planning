@Planning = React.createClass
  mixins: [ ReactMeteor.Mixin ]
  startMeteorSubscriptions: ->
    Meteor.subscribe 'users'
    Meteor.subscribe 'plannings'
  getMeteorState: ->
    state =
      days: []
      tasks: []
      duties: []
      people: Meteor.users.find().fetch()
      onlyMe: Session.get('onlyMe')
    if @props.planning
      state.days = @props.planning.days
      state.tasks = @props.planning.tasks
      state.duties = @props.planning.duties
    state
  setOnlyMe: (value) ->
    Session.set('onlyMe', value)
    @setState onlyMe: value
  render: ->
    <div>
      <div className="pull-right"><PersonFilter setOnlyMe={@setOnlyMe} onlyMe={@state.onlyMe} /></div>
      <h2>{@props.planning.name}</h2>
      <Schedule planning={@props.planning} tasks={@state.tasks} days={@state.days} duties={@state.duties} onlyMe={@state.onlyMe} />
    </div>

PersonFilter = React.createClass
  setOnlyMeToTrue: ->
    @props.setOnlyMe(true)
  setOnlyMeToFalse: ->
    @props.setOnlyMe(false)
  render: ->
    <ul className="nav nav-pills">
      <li className={'active' if @props.onlyMe}>
        <a onClick={@setOnlyMeToTrue}>Uniquement moi</a>
      </li>
      <li className={'active' unless @props.onlyMe}>
        <a onClick={@setOnlyMeToFalse}>Tout le monde</a>
      </li>
    </ul>

Schedule = React.createClass
  render: ->
    lines = @props.days.map (day) =>
      <ScheduleLine planning={@props.planning} tasks={@props.tasks} day={day} duties={@props.duties} onlyMe={@props.onlyMe} />
    <div className="schedule-wrapper">
      <table id="schedule" className="table table-striped table-bordered">
        <thead>
          <ScheduleHeader tasks={@props.tasks} />
        </thead>
        <tbody>
          {lines}
        </tbody>
      </table>
    </div>

ScheduleHeader = React.createClass
  render: ->
    tasks = @props.tasks.map (task) ->
      <th><strong>{task.name}</strong></th>
    <tr>
      <th></th>
      {tasks}
    </tr>

ScheduleLine = React.createClass
  render: ->
    cells = @props.tasks.map (task) =>
      <ScheduleCell planning={@props.planning} day={@props.day} task={task} duties={@props.duties} presences={@props.presences} people={@props.people} onlyMe={@props.onlyMe} />
    <tr className="day-no-#{moment(@props.day.date).format('e')}">
      <th><DayName planningId={@props.planningId} day={@props.day} /></th>
      {cells}
    </tr>

DayName = React.createClass
  getInitialState: ->
    { formIsVisible: false }
  showForm: ->
    @setState formIsVisible: true
  hideForm: ->
    @setState formIsVisible: false
  updateDayName: (dayName) ->
    @hideForm()
    Meteor.call 'updateDayName', @props.planningId, @props.day, dayName
  render: ->
    if @state.formIsVisible
      <DayForm originalValue={@props.day.name} onSubmit={@updateDayName} onCancel={@hideForm} />
    else
      <strong onClick={@showForm} title="Cliquez pour modifier">{@props.day.name}</strong>

ScheduleCell = React.createClass
  answerDuty: (personId, value) ->
    Meteor.call('answerNotification', @props.planning.slug, @props.day._id, @props.task._id, personId, value)
  isCurrentUser: (person) ->
    person._id == Meteor.userId()
  render: ->
    peopleList = @props.duties[k(@props.day) + ',' + k(@props.task)]
    if peopleList
      peopleList = peopleList.findAll (person) => person.confirmation == true or @isCurrentUser(person)
      if @props.onlyMe
        peopleList = peopleList.findAll (person) => @isCurrentUser(person)
      people = peopleList.map (person) =>
        <Person person={person} avatar=true mailStatus=true answerDuty={@answerDuty} isCurrentUser={@isCurrentUser(person)} />
    <td>{people}</td>

Person = React.createClass
  getInitialState: ->
    { wobble: false }
  componentWillReceiveProps: (nextProps) ->
    if nextProps.person.confirmation != @props.person.confirmation
      @setState
        wobble: nextProps.person.confirmation != undefined
  getPerson: ->
    Meteor.users.findOne _id: @props.person._id
  randomWidth: ->
    40 + Math.floor(Math.random() * 10)
  acceptDuty: ->
    @props.answerDuty(@props.person._id, true)
  rejectDuty: ->
    @props.answerDuty(@props.person._id, false)
  render: ->
    person = @getPerson()
    confirmation = @props.person.confirmation
    className = 'person alert '
    if @props.isCurrentUser
      if confirmation == undefined
        className += 'neutral background-fade'
      else if confirmation == true
        className += 'good background-fade '
        className += 'hvr-wobble-vertical' if @state.wobble
      else if confirmation == false
        className += 'bad  background-fade '
        className += 'hvr-wobble-horizontal' if @state.wobble
    else
      className += 'neutral background-fade'
    buttons = if @props.isCurrentUser
      <div className="buttons">
        <i className="fa fa-check accept-duty text-success #{if @props.person.confirmation == true then 'selected' else ''}" onClick={@acceptDuty} />
        <i className="fa fa-times reject-duty text-danger #{if @props.person.confirmation == false then 'selected' else ''}" onClick={@rejectDuty} />
      </div>
    if person
      <div className={className}>
        {displayName(person)}
        {buttons}
      </div>
    else
      null
