@UsersPresences = React.createClass
  usersWhoAnswered: ->
    sortUsers @props.planning.peopleWhoAnswered.map (userId) => @props.users.find(_id: userId)
  usersWhoDidNotAnswer: ->
    sortUsers @props.users.findAll (user) =>
      @props.planning.peopleWhoAnswered.indexOf(user._id) < 0 and @props.planning.unavailableTheWholeMonth.indexOf(user._id) < 0
  render: ->
    <div>
      <h1>
        Réponses pour les disponibilités de {@props.planning.name}
        <div className="pull-right">
          <SendAvailabilityReminderButton planning={@props.planning} />
        </div>
      </h1>
      <PresencesTable planning={@props.planning} usersWhoAnswered={@usersWhoAnswered()}/>
      <h2>{"N'ont pas répondu"}</h2>
      <ul className="list-unstyled people-who-did-not-answer">
        {@usersWhoDidNotAnswer().map (user) -> <User user={user} />}
      </ul>
    </div>

SendAvailabilityReminderButton = React.createClass
  getInitialState: ->
    sending: false
    showingSuccess: false
  sendAvailabilityReminder: (e) ->
    e.preventDefault()
    if confirm("Vous êtes sur le point d'envoyer une relance à tous les bénévoles qui n'ont pas encore donné leurs disponibilités.\n\nÊtes-vous sûr ?")
      @setState sending: true
      Meteor.call 'sendAvailabilityReminder', @props.planning._id, (error, data) =>
        @setState
          sending: false
          showingSuccess: true
        setTimeout (=> @setState showingSuccess: false), 5000
  render: ->
    className = "send-emails-button send-availability-emails-button btn "
    if @state.showingSuccess
      inner = <i className="fa fa-check-circle-o" />
      className += 'btn-success with-icon'
      style = width: '50px'
    else if @state.sending
      inner = <i className="fa fa-spinner fa-spin" />
      className += 'btn-primary with-icon'
      style = width: '50px'
    else
      inner = <span><i className="fa fa-envelope" />Envoyer un e-mail de relance</span>
      className += 'btn-primary'
    <button className={className} style={style} onClick={@sendAvailabilityReminder}>{inner}</button>

@PresencesTable = React.createClass
  rows: ->
    eventsByDate = @props.planning.events.groupBy('date')
    _.flatten Object.keys(eventsByDate).map (date) =>
      events = eventsByDate[date]
      events.map (event, index) =>
        rowspan = events.length if index == 0
        <Rows planning={@props.planning} usersWhoAnswered={@props.usersWhoAnswered} date={date} event={event} rowspan={rowspan} />
  render: ->
    <table className="table table-bordered user-presences-table">
      <tr>
        <th colSpan="2"></th>
        <th>Disponibles</th>
        <th>Non disponibles</th>
      </tr>
      {@rows()}
    </table>

Rows = React.createClass
  usersWhoCheckedPresence: ->
    @props.event.availablePeople.map (userId) =>
      @props.usersWhoAnswered.find _id: userId
  availableUsers: ->
    @usersWhoCheckedPresence().findAll (user) =>
      @props.planning.unavailableTheWholeMonth.indexOf(user._id) < 0
  unavailableUsers: ->
    _.difference @props.usersWhoAnswered, @availableUsers()
  dateColumn: ->
    <th className="event-date" rowSpan={@props.rowspan}>
      {moment(@props.event.date).format('dddd DD').humanize()}
    </th>
  render: ->
    <tr>
      {@dateColumn() if @props.rowspan}
      <th className="event-name">
        {@props.event.name}
        <span className="event-detail">{@props.event.detail}</span>
      </th>
      <td className="people-list">
        <ul className="list-unstyled available-people">
          {@availableUsers().map (user) -> <User user={user} />}
        </ul>
      </td>
      <td className="people-list">
        <ul className="list-unstyled unavailable-people">
          {@unavailableUsers().map (user) -> <User user={user} />}
        </ul>
      </td>
    </tr>

User = React.createClass
  render: ->
    <li>
      {displayName(@props.user)}
    </li>