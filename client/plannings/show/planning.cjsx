userHasDutyForDay = (planning, day) ->
  _.find planning.duties, (duties, key) ->
    key.split(',')[0] == day._id and duties.find (duty) -> duty._id == Meteor.userId()

userHasDutyForTask = (planning, task) ->
  _.find planning.duties, (duties, key) ->
    key.split(',')[1] == task._id and duties.find (duty) -> duty._id == Meteor.userId()

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
      state.duties = @props.planning.duties
      if state.onlyMe || !@props.planning.complete
        state.days = @props.planning.days.findAll (day) => userHasDutyForDay(@props.planning, day)
        state.tasks = @props.planning.tasks.findAll (task) => userHasDutyForTask(@props.planning, task)
      else
        state.days = @props.planning.days
        state.tasks = @props.planning.tasks
    state
  setOnlyMe: (value) ->
    Session.set('onlyMe', value)
    if value == true
      @setState
        onlyMe: true
        days: @props.planning.days.findAll (day) => userHasDutyForDay(@props.planning, day)
        tasks: @props.planning.tasks.findAll (task) => userHasDutyForTask(@props.planning, task)
    else
      @setState
        onlyMe: false
        days: @props.planning.days
        tasks: @props.planning.tasks
  render: ->
    <div>
      {<div className="pull-right"><PersonFilter setOnlyMe={@setOnlyMe} onlyMe={@state.onlyMe} /></div> if @props.planning.complete}
      <h2>
        {@props.planning.name}
        {<button className="downloadPlanning btn btn-primary"><i className="fa fa-download"></i>Télécharger le planning</button> if @props.planning.complete}
      </h2>
      <Schedule planning={@props.planning} tasks={@state.tasks} days={@state.days} duties={@state.duties} />
    </div>

PersonFilter = React.createClass
  setOnlyMeToTrue: ->
    @props.setOnlyMe(true)
  setOnlyMeToFalse: ->
    @props.setOnlyMe(false)
  render: ->
    <ul className="nav nav-pills">
      <li className={'active' if @props.onlyMe}>
        <a onClick={@setOnlyMeToTrue}>Voir uniquement mes jours</a>
      </li>
      <li className={'active' unless @props.onlyMe}>
        <a onClick={@setOnlyMeToFalse}>Voir tout le planning</a>
      </li>
    </ul>

Schedule = React.createClass
  getInitialState: ->
    tasks: @props.tasks
  filterTasks: (term) ->
    filteredTasks = @props.tasks.findAll (task) ->
      getSlug(task.name).fuzzy getSlug(term)
    @setState tasks: filteredTasks
  render: ->
    lines = @props.days.map (day) =>
      <ScheduleLine planning={@props.planning} tasks={@state.tasks} day={day} duties={@props.duties} />
    <div className="schedule-wrapper">
      <table id="schedule" className="table-bordered">
        <thead>
          <ScheduleHeader tasks={@state.tasks} filterTasks={@filterTasks} />
        </thead>
        <tbody>
          {lines}
        </tbody>
      </table>
    </div>

ScheduleHeader = React.createClass
  onInputChange: ->
    @props.filterTasks @refs.search.getDOMNode().value.trim()
  render: ->
    tasks = @props.tasks.map (task) ->
      if task.description and task.description.trim() != ''
        <ReactBootstrap.OverlayTrigger trigger='hover' placement='bottom' rootClose={true} overlay={<ReactBootstrap.Popover><strong>{task.description}</strong></ReactBootstrap.Popover>}>
          <th className="with-info">
            <strong>{task.name}</strong>
            <i className="info-popover fa fa-question"></i>
          </th>
        </ReactBootstrap.OverlayTrigger>
      else
        <th><strong>{task.name}</strong></th>
    <tr>
      <th>
        <input type="text" ref="search" onChange={@onInputChange} className="form-control filterTasks" placeholder="Rechercher une tâche" />
      </th>
      {tasks}
    </tr>

ScheduleLine = React.createClass
  render: ->
    cells = @props.tasks.map (task) =>
      <ScheduleCell planning={@props.planning} day={@props.day} task={task} duties={@props.duties} presences={@props.presences} people={@props.people} />
    <tr className="day-no-#{moment(@props.day.date).format('e')}">
      <th><strong>{@props.day.name}</strong></th>
      {cells}
    </tr>

ScheduleCell = React.createClass
  answerDuty: (personId, value) ->
    successPopup()
    Meteor.call('answerNotification', @props.planning.slug, @props.day._id, @props.task._id, personId, value)
  isCurrentUser: (person) ->
    person._id == Meteor.userId()
  render: ->
    if peopleList = @props.duties[k(@props.day) + ',' + k(@props.task)]
      unless @props.planning.complete
        peopleList = peopleList.findAll (person) =>
          @isCurrentUser(person)
      people = peopleList.map (person) =>
        <Person person={person} planning={@props.planning} avatar=true mailStatus=true answerDuty={@answerDuty} isCurrentUser={@isCurrentUser(person)} />
    <td>{people}</td>

Person = React.createClass
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
    className = 'person '
    if @props.isCurrentUser
      if confirmation == true
        className += 'text-success'
      else if confirmation == false
        className += 'text-danger'
    else
      className += 'neutral background-fade'
    buttons = if @props.isCurrentUser
      <div className="buttons">
        <i className="fa fa-check accept-duty text-success #{if @props.person.confirmation == true then 'selected' else ''}" onClick={@acceptDuty} />
        <i className="fa fa-times reject-duty text-danger #{if @props.person.confirmation == false then 'selected' else ''}" onClick={@rejectDuty} />
      </div>
    if person
      <div className={className}>
        {displayName(person) if @props.planning.complete}
        {buttons}
      </div>
    else
      null
