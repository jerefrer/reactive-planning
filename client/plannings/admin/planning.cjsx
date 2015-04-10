@Plannings = new (Meteor.Collection)('plannings')
@SoundsToPlay = new (Meteor.Collection)('sounds_to_play')
DragDropMixin = ReactDND.DragDropMixin
ItemTypes = PERSON: 'person'

@Scheduler = React.createClass
  mixins: [ ReactMeteor.Mixin ]
  startMeteorSubscriptions: ->
    Meteor.subscribe 'users'
    Meteor.subscribe 'plannings'
    Meteor.subscribe 'sounds_to_play'
  getMeteorState: ->
    state =
      days: []
      tasks: []
      duties: []
      presences: []
      people: Meteor.users.find().fetch()
    if @props.planning
      state.days = @props.planning.days
      state.tasks = @props.planning.tasks
      state.duties = @props.planning.duties
      state.presences = @props.planning.presences
    state
  clearDuties: (e) ->
    e.preventDefault()
    Meteor.call 'clearDuties', @props.planning._id
  render: ->
    sound_to_play = SoundsToPlay.find().fetch()[0]
    if sound_to_play
      playedSounds = Session.get('playedSounds')
      if playedSounds
        if playedSounds.indexOf(sound_to_play._id) < 0
          sound = new (buzz.sound)(sound_to_play.filename)
          sound.play()
          playedSounds.push sound_to_play._id
          Session.setPersistent 'playedSounds', playedSounds
      else
        Session.setPersistent 'playedSounds', [ sound_to_play._id ]
    <div className="row">
      <div className="col-md-9">
        <h2>
          {@props.planning.name}
          {' - '}
          <button className="btn btn-danger" onClick={@clearDuties}>Tout effacer</button>{' - '}
          <SendEmailsButton planningId={@props.planning._id} />
        </h2>
        <Schedule planningId={@props.planning._id} tasks={@state.tasks} days={@state.days} duties={@state.duties} presences={@state.presences} />
      </div>
      <div className="col-md-3">
        <h2>Bénévoles</h2>
        <PeopleList people={@state.people} />
      </div>
    </div>

SendEmailsButton = React.createClass
  getInitialState: ->
    {
      sending: false
      sent: false
    }
  sendNotifications: (e) ->
    e.preventDefault()
    if !@state.sent
      @setState sending: true
      Meteor.call 'sendEmailNotifications', @props.planningId, (error, data) =>
        @setState
          sent: true
          sending: false
  render: ->
    className = "send-emails-button btn "
    inner = undefined
    style = undefined
    if @state.sent
      inner = <i className="fa fa-check-circle-o" />
      className += 'btn-success with-icon'
      style = width: '50px'
    else if @state.sending
      inner = <i className="fa fa-spinner fa-spin" />
      className += 'btn-primary with-icon'
      style = width: '50px'
    else
      inner = 'Envoyer les e-mails'
      className += 'btn-primary'
    <button className={className} style={style} onClick={@sendNotifications}>{inner}</button>;

Schedule = React.createClass
  render: ->
    lines = @props.days.map (day) =>
      <ScheduleLine planningId={@props.planningId} tasks={@props.tasks} day={day} duties={@props.duties} presences={@props.presences} />
    <table id="schedule" className="table table-striped table-bordered">
      <thead>
        <ScheduleHeader tasks={@props.tasks} />
      </thead>
      <tbody>
        {lines}
        <tr>
          <td><AddDayCell planningId={@props.planningId} onAddDay={@handleAddDay} /></td>
          <td colSpan="5000"></td>
        </tr>
      </tbody>
    </table>


ScheduleHeader = React.createClass
  render: ->
    tasks = @props.tasks.map (task) ->
      <th><strong>{task.name}</strong></th>
    <tr>
      <td></td>
      {tasks}
    </tr>

ScheduleLine = React.createClass
  render: ->
    cells = @props.tasks.map (task) =>
      <ScheduleCell planningId={@props.planningId} day={@props.day} task={task} duties={@props.duties} presences={@props.presences} />
    <tr>
      <td><DayName planningId={@props.planningId} day={@props.day} /></td>
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
  handlePersonDrop: (person) ->
    cell = person.scheduleCell
    person.scheduleCell = null
    # Remove the schedule cell so it's not serialized to be sent to Meteor
    Meteor.call 'addPerson', @props.planningId, @props.day, @props.task, person
    if cell
      Meteor.call 'removePerson', @props.planningId, cell.props.day, cell.props.task, person
  removePerson: (person) ->
    person.scheduleCell = null
    # Remove the schedule cell so it's not serialized to be sent to Meteor
    Meteor.call 'removePerson', @props.planningId, @props.day, @props.task, person
  mixins: [ DragDropMixin ]
  statics: configureDragDrop: (register) ->
    register ItemTypes.PERSON, dropTarget:
      canDrop: (component, person) ->
        dutiesForDay = getPeople(component.props.duties, component.props.day, component.props.task)
        presencesForDay = component.props.presences[component.props.day._id]
        presencesForDay and presencesForDay.find(_id: person._id) and (!dutiesForDay or !dutiesForDay.find(_id: person._id))
      acceptDrop: (component, person) ->
        component.handlePersonDrop person
  render: ->
    removePerson = @removePerson
    peopleList = @props.duties[k(@props.day) + ',' + k(@props.task)]
    people = undefined
    if peopleList
      people = peopleList.map (personObject) =>
        <Person person={personObject} scheduleCell={@} onThrowAway={removePerson}/>
    dropState = @getDropState(ItemTypes.PERSON)
    className = undefined
    if dropState.isDragging
      className = if dropState.isHovering then 'hover' else 'allowed'
    <td {...@dropTargetFor(ItemTypes.PERSON)} className={className}>{people}</td>

Person = React.createClass
  mixins: [ DragDropMixin ]
  statics: configureDragDrop: (register) ->
    register ItemTypes.PERSON, dragSource:
      beginDrag: (component) ->
        person = component.props.person
        person.scheduleCell = component.props.scheduleCell
        # DND only passed the JS object, not the React one, so we have to explicitly set scheduleCell on the JS object
        { item: person }
      endDrag: (component, effect) ->
        if !effect
          if component.props.onThrowAway
            component.props.onThrowAway component.props.person
  getPerson: ->
    Meteor.users.findOne _id: @props.person._id
  cycleStatus: ->
    cell = @props.scheduleCell
    Meteor.call 'cycleStatus', cell.props.planningId, cell.props.day._id, cell.props.task._id, @props.person._id
  render: ->
    person = @getPerson()
    if person
      positive = @props.person.positive
      className = 'alert '
      if positive == undefined
        className += 'neutral background-fade'
      else if positive == true
        className += 'good background-fade hvr-wobble-vertical'
      else if positive == false
        className += 'bad  background-fade hvr-wobble-horizontal'
      <div className={className}
           {...@dragSourceFor(ItemTypes.PERSON)}
           onDoubleClick={@cycleStatus} >
        {person.username}
      </div>
    else
      null

AddDayCell = React.createClass
  getInitialState: ->
    { formIsVisible: false }
  showForm: ->
    @setState formIsVisible: true
  hideForm: ->
    @setState formIsVisible: false
  addDay: (dayName) ->
    @hideForm()
    Meteor.call 'addDay', @props.planningId, dayName
  render: ->
    if @state.formIsVisible
      <DayForm onSubmit={@addDay} onCancel={@hideForm} />
    else
      <a href="#" onClick={@showForm}>Ajouter un jour</a>

DayForm = React.createClass
  componentDidMount: ->
    domNode = @refs.dayName.getDOMNode()
    if @props.originalValue
      domNode.value = @props.originalValue
    domNode.select()
  handleSubmit: (e) ->
    e.preventDefault()
    dayName = @refs.dayName.getDOMNode().value.trim()
    @props.onSubmit dayName
    @refs.dayName.getDOMNode().value = ''
  render: ->
    <div>
      <form onSubmit={@handleSubmit}>
        <input className="form-control" ref="dayName" />
      </form>
      <a href="#" onClick={@props.onCancel} className="pull-right">Annuler</a>
    </div>

PeopleList = React.createClass
  filterBySearchTerm: (term) ->
    @setState people: @props.people.findAll (user) ->
      getSlug(user.username).fuzzy getSlug(term)
  render: ->
    people = if @state then @state.people else @props.people
    # Hack, seems that getInitialState gets called the first time when everything is empty, and not the second time when it's filled
    people_list = people.map (person) ->
      <li><Person person={person}/></li>
    <div id="people-list">
      <PeopleFilters onChange={@filterBySearchTerm} />
      <ul className="list-unstyled">{people_list}</ul>
    </div>

PeopleFilters = React.createClass
  handleChange: ->
    @props.onChange @refs.name.getDOMNode().value.trim()
  render: ->
    <div className="form-group form-inline">
      <label className="control-label">Nom</label>
      <input type="text" ref="name" onChange={@handleChange} className="form-control" />
    </div>
