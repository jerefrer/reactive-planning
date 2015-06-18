@Home = React.createClass
  render: ->
    plannings = @props.plannings.map (planning) ->
      <Planning planning={planning} />
    <div className="dashboard">
      {plannings}
    </div>

Planning = React.createClass
  userDuties: ->
    duties = @props.planning.duties
    Object.keys(duties).map( (dayTaskKey) ->
      duties[dayTaskKey].findAll (duty) ->
        duty._id == Meteor.userId()
    ).flatten()
  userProvidedHisAvailabilities: ->
    @props.planning.peopleWhoAnswered.indexOf(Meteor.userId()) >= 0
  render: ->
    userDuties = @userDuties()
    numberOfDuties = userDuties.length
    userProvidedHisAvailabilities = @userProvidedHisAvailabilities()
    if @props.planning.availabilityEmailSent
      if userProvidedHisAvailabilities or numberOfDuties > 0
        <DutiesCount planning={@props.planning} userDuties={userDuties} numberOfDuties={numberOfDuties} />
      else
        <AskForAvailabilities planning={@props.planning} />
    else
      <NotReady planning={@props.planning} />

DutiesCount = React.createClass
  goToAvailabilitiesPage: ->
    window.location = "/planning/#{@props.planning.slug}/presences"
  numberOfDutiesToAnswerTo: (duties) ->
    duties.count (duty) ->
      duty.confirmation == undefined
  nextDuty: ->
    duties = @props.planning.duties
    day = @props.planning.days.find (day) ->
      Object.keys(duties).find (dayTaskKey) ->
        dayTaskKey.split(',')[0] == day._id and duties[dayTaskKey].find (duty) -> duty._id == Meteor.userId()
    day and day.name
  render: ->
    lines = []
    slug = @props.planning.slug
    nextDuty = @nextDuty()
    numberOfDutiesToAnswerTo = @numberOfDutiesToAnswerTo(@props.userDuties)
    if numberOfDutiesToAnswerTo > 0
      barColor = 'yellow'
      lines.push(
        <div className="status alerte">
          <i className="fa fa-exclamation-circle" />
          <span>
            Vous avez
            <strong> {"#{numberOfDutiesToAnswerTo} demande#{numberOfDutiesToAnswerTo > 1 && 's' || ''} en attente"} </strong>
          </span>
        </div>
      )
    else
      barColor = 'green'
      lines.push(<span><span className="count">{@props.numberOfDuties}</span> rendez-vous</span>)
      if nextDuty
        lines.push(<span> – Le prochain <strong>{nextDuty}</strong></span>)
    <div className="planning">
      <StatusBar color={barColor} />
      <div className="content">
        <div className="left">
          <div className="name">{@props.planning.name}</div>
          <div className="status">{lines}</div>
        </div>
        <div className="links">
          <a className="half-link" href={"/planning/#{slug}"}>
            Voir le planning
            <i className="fa fa-chevron-right"></i>
          </a>
          <a className="half-link bottom" href={"/planning/#{slug}/presences"}>
            Mes disponibilités
            <i className="fa fa-chevron-right"></i>
          </a>
        </div>
      </div>
    </div>

AskForAvailabilities = React.createClass
  goToAvailabilitiesPage: ->
    window.location = "/planning/#{@props.planning.slug}/presences"
  render: ->
    <div className="planning hoverable" onClick={@goToAvailabilitiesPage}>
      <StatusBar color='yellow' />
      <div className="content">
        <div className="left">
          <div className="name">{@props.planning.name}</div>
          <div className="status alerte">
            <i className="fa fa-exclamation-circle" />
            <span>
              {"Vous n'avez pas encore indiqué"}
              <strong> vos disponilités</strong>
            </span>
          </div>
        </div>
        <div className="links">
          <a className="single-link">
            <i className="fa fa-chevron-right"></i>
          </a>
        </div>
      </div>
    </div>

NotReady = React.createClass
  render: ->
    <div className="planning">
      <StatusBar color='yellow' />
      <div className="content">
        <div className="left">
          <div className="name">{@props.planning.name}</div>
          <div className="status">
            <i className="fa fa-exclamation-circle" />
            {"Toujours en cours d'élaboration"}
          </div>
        </div>
      </div>
    </div>

StatusBar = React.createClass
  render: ->
    className = "status-bar "
    className += @props.color
    <div className={className}></div>
