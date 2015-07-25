@UsersPresences = React.createClass
  usersWhoAnswered: ->
    sortUsers @props.planning.peopleWhoAnswered.map (userId) => @props.users.find(_id: userId)
  usersWhoDidNotAnswer: ->
    sortUsers @props.users.findAll (user) =>
      @props.planning.peopleWhoAnswered.indexOf(user._id) < 0 and @props.planning.unavailableTheWholeMonth.indexOf(user._id) < 0
  render: ->
    <div>
      <h1>
        Réponses pour les disponibilités de <a href="/planning/{@props.planning.slug}/admin">{@props.planning.name}</a>
        <div className="pull-right">
          <SendAvailabilityReminderButton planning={@props.planning} />
        </div>
      </h1>
      <div className="row">
        <div className="col-md-8">
          <PresencesTable planning={@props.planning} usersWhoAnswered={@usersWhoAnswered()}/>
        </div>
        <div className="col-md-4 people-list">
          <h2>{"N'ont pas répondu"}</h2>
          <ul className="list-unstyled people-who-did-not-answer">
            {@usersWhoDidNotAnswer().map (user) -> <User user={user} />}
          </ul>
        </div>
      </div>
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
  render: ->
    rows = @props.planning.days.map (day) =>
      <Row planning={@props.planning} usersWhoAnswered={@props.usersWhoAnswered} day={day} />
    <table className="table table-bordered user-presences-table">
      <tr>
        <th></th>
        <th>Disponibles</th>
        <th>Non disponibles</th>
      </tr>
      {rows}
    </table>

Row = React.createClass
  usersWhoCheckedPresence: ->
    if presencesForDay = @props.planning.presences[@props.day._id]
      presencesForDay.map (presence) =>
        @props.usersWhoAnswered.find _id: presence._id
    else
      []
  availableUsers: ->
    @usersWhoCheckedPresence().findAll (user) =>
      @props.planning.unavailableTheWholeMonth.indexOf(user._id) < 0
  unavailableUsers: ->
    _.difference @props.usersWhoAnswered, @availableUsers()
  render: ->
    <tr>
      <th className="day-name">{@props.day.name}</th>
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
