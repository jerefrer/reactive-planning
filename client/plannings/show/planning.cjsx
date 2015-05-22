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
      <Schedule planningId={@props.planning._id} tasks={@state.tasks} days={@state.days} duties={@state.duties} onlyMe={@state.onlyMe} />
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
      <ScheduleLine planningId={@props.planningId} tasks={@props.tasks} day={day} duties={@props.duties} onlyMe={@props.onlyMe} />
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
      <ScheduleCell planningId={@props.planningId} day={@props.day} task={task} duties={@props.duties} presences={@props.presences} people={@props.people} onlyMe={@props.onlyMe} />
    <tr>
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
  render: ->
    peopleList = @props.duties[k(@props.day) + ',' + k(@props.task)]
    if peopleList
      peopleList = peopleList.findAll (person) -> person.confirmation == true
      if @props.onlyMe
        peopleList = peopleList.findAll (person) -> person._id == Meteor.userId()
      people = peopleList.map (personObject) =>
        <Person person={personObject} avatar=true mailStatus=true />
    <td>{people}</td>

Person = React.createClass
  getPerson: ->
    Meteor.users.findOne _id: @props.person._id
  randomWidth: ->
    40 + Math.floor(Math.random() * 10)
  render: ->
    person = @getPerson()
    if person
      <div className='person alert neutral'>
        {<img src="http://lorempixel.com/#{@randomWidth()}/#{@randomWidth()}/people" className="img-circle" /> if @props.avatar}
        {person.username}
      </div>
    else
      null
