SoundsToPlay = new (Meteor.Collection)('sounds_to_play')
DragDropMixin = ReactDND.DragDropMixin
ItemTypes = PERSON: 'person'

@PlanningAdmin = React.createClass
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
      peopleWhoAnswered: []
      people: Meteor.users.find().fetch()
    if @props.planning
      state.days = @props.planning.days
      state.tasks = @props.planning.tasks
      state.duties = @props.planning.duties
      state.presences = @props.planning.presences
      state.emailsToSend = @props.planning.emailsToSend
      state.emailsSent = @props.planning.emailsSent
      state.peopleWhoAnswered = @props.planning.peopleWhoAnswered
    state
  clearDuties: (e) ->
    e.preventDefault()
    if confirm("Êtes-vous sûr ?")
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
        <button className="btn btn-danger" onClick={@clearDuties}>Tout effacer</button>
        <SendAvailabilityEmailNotificationsButton planning={@props.planning} />
        <SendPresenceEmailNotificationsButton planningId={@props.planning._id} emailsToSend={@state.emailsToSend} emailsSent={@state.emailsSent} />
      </h2>
      <Schedule planning={@props.planning} tasks={@state.tasks} days={@state.days} duties={@state.duties} presences={@state.presences} people={@state.people} peopleWhoAnswered={@state.peopleWhoAnswered} />
    </div>

SendAvailabilityEmailNotificationsButton = React.createClass
  getInitialState: ->
    sending: false
    showingSuccess: false
  sendAvailabilityEmailNotifications: (e) ->
    e.preventDefault()
    @setState sending: true
    Meteor.call 'sendAvailabilityEmailNotifications', @props.planning._id, (error, data) =>
      @setState
        sending: false
        showingSuccess: true
      setTimeout (=> @setState showingSuccess: false), 5000
  render: ->
    return null unless (not @props.planning.availabilityEmailSent) or @state.sending or @state.showingSuccess
    className = "send-emails-button send-availability-emails-button btn "
    inner = undefined
    style = undefined
    if @state.showingSuccess
      inner = <i className="fa fa-check-circle-o" />
      className += 'btn-success with-icon'
      style = width: '50px'
    else if @state.sending
      inner = <i className="fa fa-spinner fa-spin" />
      className += 'btn-primary with-icon'
      style = width: '50px'
    else
      inner = <span><i className="fa fa-envelope" />Demander les disponibilités</span>
      className += 'btn-primary'
    <span>
      {' - '}
      <button className={className} style={style} onClick={@sendAvailabilityEmailNotifications}>{inner}</button>
    </span>

SendPresenceEmailNotificationsButton = React.createClass
  getInitialState: ->
    { sending: false }
  sendPresenceEmailNotifications: (e) ->
    e.preventDefault()
    if @props.emailsToSend
      @setState sending: true
      Meteor.call 'sendPresenceEmailNotifications', @props.planningId, (error, data) =>
        @setState
          sending: false
  render: ->
    return null unless @props.emailsToSend
    className = "send-emails-button send-confirmation-emails-button btn "
    inner = undefined
    style = undefined
    if @props.emailsSent
      inner = <i className="fa fa-check-circle-o" />
      className += 'btn-success with-icon'
      style = width: '50px'
    else if @state.sending
      inner = <i className="fa fa-spinner fa-spin" />
      className += 'btn-primary with-icon'
      style = width: '50px'
    else
      inner = <span><i className="fa fa-envelope" />Envoyer les e-mails de confirmation</span>
      className += 'btn-primary'
    <span>
      {' - '}
      <button className={className} style={style} onClick={@sendPresenceEmailNotifications}>{inner}</button>
    </span>

Schedule = React.createClass
  render: ->
    lines = @props.days.map (day) =>
      <ScheduleLine planning={@props.planning} tasks={@props.tasks} day={day} duties={@props.duties} presences={@props.presences} people={@props.people} peopleWhoAnswered={@props.peopleWhoAnswered}/>
    <div className="schedule-wrapper">
      <table id="schedule" className="table table-bordered">
        <thead>
          <ScheduleHeader tasks={@props.tasks} />
        </thead>
        <tbody>
          {lines}
          <tr>
            <th><AddDayCell planning={@props.planning} onAddDay={@handleAddDay} /></th>
            <th colSpan="5000"></th>
          </tr>
        </tbody>
      </table>
    </div>

ScheduleHeader = React.createClass
  render: ->
    tasks = @props.tasks.map (task) ->
      <th><strong>{task.name}</strong></th>
    <tr>
      <th className="day-column"></th>
      {tasks}
    </tr>

ScheduleLine = React.createClass
  render: ->
    cells = @props.tasks.map (task) =>
      <ScheduleCell planningId={@props.planning._id} day={@props.day} task={task} duties={@props.duties} presences={@props.presences} people={@props.people} peopleWhoAnswered={@props.peopleWhoAnswered} />
    <tr className="day-no-#{moment(@props.day.date).format('e')}">
      <th><DayName planning={@props.planning} day={@props.day} /></th>
      {cells}
    </tr>

DayName = React.createClass
  getInitialState: ->
    { formIsVisible: false }
  showForm: ->
    @setState formIsVisible: true
  hideForm: ->
    @setState formIsVisible: false
  updateDay: (dayName, dayDate) ->
    @hideForm()
    Meteor.call 'updateDay', @props.planningId, @props.day, dayName, dayDate
  render: ->
    if @state.formIsVisible
      <DayForm planning={@props.planning} originalDayDate={@props.day.date} originalDayName={@props.day.name} onSubmit={@updateDay} onCancel={@hideForm} />
    else
      <strong onClick={@showForm} title="Cliquez pour modifier">{@props.day.name}</strong>

ScheduleCell = React.createClass
  render: ->
    peopleList = @props.duties[k(@props.day) + ',' + k(@props.task)]
    people = undefined
    if peopleList
      people = peopleList.map (personObject) =>
        <Person person={personObject} avatar=true mailStatus=true />
    <ReactBootstrap.ModalTrigger modal={<AddPersonModal planningId={@props.planningId} day={@props.day} task={@props.task} duties={@props.duties} presences={@props.presences} people={@props.people} peopleWhoAnswered={@props.peopleWhoAnswered} />}>
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
      <div className={className} onDoubleClick={@cycleStatus} >
        {person.username}
        {<i className="mail-to-be-sent fa fa-envelope" /> if @props.mailStatus and not @props.person.emailSent}
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
  addDay: (dayName, dayDate) ->
    @hideForm()
    Meteor.call 'addDay', @props.planning._id, dayName, dayDate
  render: ->
    if @state.formIsVisible
      <DayForm planning={@props.planning} onSubmit={@addDay} onCancel={@hideForm} />
    else
      <a href="#" onClick={@showForm}>Ajouter un jour</a>

DayForm = React.createClass
  thereIsANameDifferentFromDateName: ->
    @props.originalDayDate and
    @props.originalDayName.trim() != '' and
    @props.originalDayName.toLowerCase() != moment(@props.originalDayDate).format('dddd DD')
  getInitialState: ->
    showNameField: @thereIsANameDifferentFromDateName()
  showInput: (e) ->
    e.preventDefault()
    @setState showNameField: true
  hideInput: (e) ->
    e.preventDefault()
    @setState showNameField: false
  handleSubmit: (e) ->
    e.preventDefault()
    dayDate = @refs.dayDate.getDOMNode().value.trim()
    dayName = @refs.dayName && @refs.dayName.getDOMNode().value.trim() || @refs.datepicker.getDOMNode().value.trim()
    @props.onSubmit dayName, dayDate
  componentDidMount: ->
    $('.datepicker-trigger').datepicker
      format: 'DD dd'
      autoclose: true
      language: 'fr'
      weekStart: 1
      startDate: new Date(@props.planning.year, @props.planning.month)
      endDate: moment(new Date(@props.planning.year, @props.planning.month)).endOf('month').toDate()
    $('.datepicker-trigger').datepicker().on 'changeDate', (e) =>
      @refs.dayDate.getDOMNode().value = e.format('dd-mm-yyyy')
      @refs.dayName.getDOMNode().value = e.format('DD dd') if @refs.dayName
    $('.datepicker-trigger').datepicker('setDate', @props.originalDayDate) if @props.originalDayDate
    @refs.dayName.getDOMNode().value = @props.originalDayName if @state.showNameField
  componentDidUpdate: ->
    if @state.showNameField
      @refs.dayName.getDOMNode().value = @refs.datepicker.getDOMNode().value
      @refs.dayName.getDOMNode().select()
  render: ->
    dayNameInput = if @state.showNameField
      <div className="dayNameInputGroup">
        <input className="form-control" ref="dayName" placeholder="Nom" />
        <a href='#' onClick={@hideInput}><i className="fa fa-times-circle-o" /></a>
      </div>
    else
      <a href="#" onClick={@showInput} className="customizeDayName">Donner un nom ?</a>
    <div className="dayForm">
      <form onSubmit={@handleSubmit}>
        <input className="hidden-date" ref="dayDate" type="hidden" />
        <input className="set-due-date form-control datepicker-trigger" ref="datepicker" placeholder="Date" />
        {dayNameInput}
        <button className="btn btn-primary pull-left">Valider</button>
      </form>
      <a href="#" onClick={@props.onCancel} className="cancel pull-right">Annuler</a>
    </div>

AddPersonModal = React.createClass
  render: ->
    <ReactBootstrap.Modal {...@props} bsStyle='primary' title="#{@props.day.name} - #{@props.task.name}" animation>
      <div className='modal-body'>
        <div className="row same-height-columns">
          <PeopleList planningId={@props.planningId} people={@props.people} day={@props.day} task={@props.task} duties={@props.duties} presences={@props.presences} peopleWhoAnswered={@props.peopleWhoAnswered} />
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
  personChecked: (person) ->
    dutiesForDay = getPeople(@props.duties, @props.day, @props.task)
    !!dutiesForDay.find(_id: person._id)
  availablePeople: (people) ->
    dutiesForDay = getPeople(@props.duties, @props.day, @props.task)
    presencesForDay = @props.presences[@props.day._id]
    people.findAll (person) ->
      presencesForDay and presencesForDay.find(_id: person._id)
  peopleWhoDidNotAnswer: (people) ->
    people.findAll (person) =>
      @props.peopleWhoAnswered.indexOf(person._id) < 0
  unavailablePeople: (people, availablePeople, peopleWhoDidNotAnswer) ->
    dutiesForDay = getPeople(@props.duties, @props.day, @props.task)
    _.difference(_.difference(people, availablePeople), peopleWhoDidNotAnswer)
  buildList: (people) ->
    people.map (person) =>
      personChecked = @personChecked(person)
      <PersonForDuty person={person} selected={personChecked} handleClick={personChecked && @removePerson || @addPerson} />
  addPerson: (person) ->
    Meteor.call 'addPerson', @props.planningId, @props.day, @props.task, person
  removePerson: (person) ->
    Meteor.call 'removePerson', @props.planningId, @props.day, @props.task, person
  render: ->
    people = if @state then @state.people else @props.people
    # Hack, seems that getInitialState gets called the first time when everything is empty, and not the second time when it's filled
    availablePeople = @availablePeople(people)
    peopleWhoDidNotAnswer = @peopleWhoDidNotAnswer(people)
    unavailablePeople = @unavailablePeople(people, availablePeople, peopleWhoDidNotAnswer)
    availablePeopleList = @buildList(availablePeople)
    peopleWhoDidNotAnswerList = @buildList(peopleWhoDidNotAnswer)
    unavailablePeopleList = @buildList(unavailablePeople)
    <div className="people-list col-md-6">
      <PeopleFilters onChange={@filterBySearchTerm} />
      <div className="available-people">
        <h3>Disponibles</h3>
        <ul className="list-unstyled">{availablePeopleList}</ul>
      </div>
      <div className="people-who-did-not-answer">
        <h3>Sans réponse</h3>
        <ul className="list-unstyled">{peopleWhoDidNotAnswerList}</ul>
      </div>
      <div className="unavailable-people">
        <h3>Indisponibles</h3>
        <ul className="list-unstyled">{unavailablePeopleList}</ul>
      </div>
    </div>

PeopleFilters = React.createClass
  handleChange: ->
    @props.onChange @refs.name.getDOMNode().value.trim()
  render: ->
    <div className="form-group form-inline">
      <label className="control-label">Nom</label>
      <input type="text" ref="name" onChange={@handleChange} className="form-control" />
    </div>

PersonForDuty = React.createClass
  addOrRemovePerson: ->
    @props.handleClick(@props.person)
  render: ->
    className = ''
    className += 'selected' if @props.selected
    <li className={className} onClick={@addOrRemovePerson}>
      <span className="bullet"></span>
      <span className="check"><i className="fa fa-check"/></span>
      <span className="remove"><i className="fa fa-times"/></span>
      <span className="name">{@props.person.username}</span>
    </li>
