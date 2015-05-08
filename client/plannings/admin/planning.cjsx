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
    <div>
      <h2>
        {@props.planning.name}
        {' - '}
        <button className="btn btn-danger" onClick={@clearDuties}>Tout effacer</button>{' - '}
        <SendEmailsButton planningId={@props.planning._id} />
      </h2>
      <Schedule planningId={@props.planning._id} tasks={@state.tasks} days={@state.days} duties={@state.duties} presences={@state.presences} people={@state.people} />
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
      <ScheduleLine planningId={@props.planningId} tasks={@props.tasks} day={day} duties={@props.duties} presences={@props.presences} people={@props.people} />
    <div className="schedule-wrapper">
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
    </div>

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
      <ScheduleCell planningId={@props.planningId} day={@props.day} task={task} duties={@props.duties} presences={@props.presences} people={@props.people} />
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
  render: ->
    peopleList = @props.duties[k(@props.day) + ',' + k(@props.task)]
    people = undefined
    if peopleList
      people = peopleList.map (personObject) =>
        <Person person={personObject} />
    <ReactBootstrap.ModalTrigger modal={<AddPersonModal planningId={@props.planningId} day={@props.day} task={@props.task} duties={@props.duties} presences={@props.presences} people={@props.people} />}>
      <td>
        {people}
      </td>
    </ReactBootstrap.ModalTrigger>

Person = React.createClass
  getInitialState: ->
    { wobble: false }
  componentWillReceiveProps: (nextProps) ->
    if nextProps.person.confirmation != @props.person.confirmation
      @setState
        wobble: nextProps.person.confirmation != undefined
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
  randomWidth: ->
    40 + Math.floor(Math.random() * 10)
  render: ->
    person = @getPerson()
    if person
      confirmation = @props.person.confirmation
      className = 'person alert '
      if confirmation == undefined
        className += 'neutral background-fade'
      else if confirmation == true
        className += 'good background-fade '
        className += 'hvr-wobble-vertical' if @state.wobble
      else if confirmation == false
        className += 'bad  background-fade '
        className += 'hvr-wobble-horizontal' if @state.wobble
      <div className={className}
           {...@dragSourceFor(ItemTypes.PERSON)}
           onDoubleClick={@cycleStatus} >
        {<img src="http://lorempixel.com/#{@randomWidth()}/#{@randomWidth()}/people" className="img-circle" /> if @props.avatar}
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

AddPersonModal = React.createClass
  render: ->
    <ReactBootstrap.Modal {...@props} bsStyle='primary' title="#{@props.day.name} - #{@props.task.name}" animation>
      <div className='modal-body'>
        <div className="row same-height-columns">
          <PeopleList people={@props.people} day={@props.day} task={@props.task} duties={@props.duties} presences={@props.presences}/>
          <div className="divider"></div>
          <PeopleForDuty planningId={@props.planningId} day={@props.day} task={@props.task} duties={@props.duties} />
        </div>
      </div>
      <div className='modal-footer'>
        <ReactBootstrap.Button onClick={@props.onRequestHide}>Fermer</ReactBootstrap.Button>
      </div>
    </ReactBootstrap.Modal>

PeopleList = React.createClass
  filterBySearchTerm: (term) ->
    @setState people: @props.people.findAll (user) ->
      getSlug(user.username).fuzzy getSlug(term)
  availablePeople: ->
    peopleList = @props.people
    dutiesForDay = getPeople(@props.duties, @props.day, @props.task)
    presencesForDay = @props.presences[@props.day._id]
    debugger
    peopleList.findAll (person) ->
      answered_yes = presencesForDay and presencesForDay.find(_id: person._id)
      already_inserted = dutiesForDay and dutiesForDay.find(_id: person._id)
      answered_yes and not already_inserted
  render: ->
    people = if @state then @state.people else @props.people
    # Hack, seems that getInitialState gets called the first time when everything is empty, and not the second time when it's filled
    people_list = @availablePeople().map (person) ->
      <li><Person person={person} avatar={true} /></li>
    <div className="people-list col-md-6">
      <h3>Disponibles</h3>
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

PeopleForDuty = React.createClass
  handlePersonDrop: (person) ->
    cell = person.scheduleCell
    person.scheduleCell = null # Remove the schedule cell so it's not sent to Meteor
    Meteor.call 'addPerson', @props.planningId, @props.day, @props.task, person
    if cell
      Meteor.call 'removePerson', @props.planningId, cell.props.day, cell.props.task, person
  removePerson: (person) ->
    person.scheduleCell = null # Remove the schedule cell so it's not sent to Meteor
    Meteor.call 'removePerson', @props.planningId, @props.day, @props.task, person
  mixins: [ DragDropMixin ]
  statics: configureDragDrop: (register) ->
    register ItemTypes.PERSON, dropTarget:
      acceptDrop: (component, person) ->
        component.handlePersonDrop person
  render: ->
    peopleList = @props.duties[k(@props.day) + ',' + k(@props.task)]
    people = undefined
    if peopleList
      people = peopleList.map (personObject) =>
        <Person person={personObject} scheduleCell={@} onThrowAway={@removePerson} avatar={true}/>
    dropState = @getDropState(ItemTypes.PERSON)
    className = React.addons.classSet
      "people-for-duty": true
      "col-md-6": true
      "drop-target": dropState.isDragging
      "drop-hover": dropState.isHovering
    <div {...@dropTargetFor(ItemTypes.PERSON)} className={className}>
      <h3>Désignés</h3>
      {people}
    </div>
