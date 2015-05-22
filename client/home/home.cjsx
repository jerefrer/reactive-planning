@Home = React.createClass
  render: ->
    plannings = @props.plannings.map (planning) ->
      <div>
        <Planning planning={planning} />
        <hr />
      </div>
    <div>
      {plannings}
    </div>

Planning = React.createClass
  userDuties: ->
    duties = @props.planning.duties
    Object.keys(duties).map( (dayTaskKey) ->
      duties[dayTaskKey].findAll (duty) ->
        duty._id == Meteor.userId()
    ).flatten()
  numberOfDutiesToAnswerTo: (duties) ->
    duties.count (duty) ->
      duty.confirmation == undefined
  userProvidedHisAvailabilities: ->
    @props.planning.peopleWhoAnswered.indexOf(Meteor.userId()) >= 0
  colorClass: (numberOfDutiesToAnswerTo) ->
    if @props.planning.availabilityEmailSent
      if not @userProvidedHisAvailabilities() or numberOfDutiesToAnswerTo > 0
        'danger'
      else
        'success'
    else
      'warning'
  render: ->
    userDuties = @userDuties()
    numberOfDutiesToAnswerTo = @numberOfDutiesToAnswerTo(userDuties)
    colorClass = @colorClass(numberOfDutiesToAnswerTo)
    <div className="row">
      <div className="col-md-4" onClick={@openPlanning}>
        <div className="background bg-#{colorClass} text-#{colorClass}">
          <div className="content">{@props.planning.name}</div>
        </div>
      </div>
      <div className="col-md-5">
        <Status planning={@props.planning} userProvidedHisAvailabilities={@userProvidedHisAvailabilities()} numberOfDuties={userDuties.length} numberOfDutiesToAnswerTo={numberOfDutiesToAnswerTo}/>
      </div>
      <div className="col-md-3">
        <Links planning={@props.planning} userProvidedHisAvailabilities={@userProvidedHisAvailabilities()} />
      </div>
    </div>

Status = React.createClass
  nextDuty: ->
    duties = @props.planning.duties
    day = @props.planning.days.find (day) ->
      Object.keys(duties).find (dayTaskKey) ->
        dayTaskKey.split(',')[0] == day._id and duties[dayTaskKey].find (duty) -> duty._id == Meteor.userId()
    day and day.name
  render: ->
    lines = []
    if @props.planning.availabilityEmailSent
      nextDuty = @nextDuty()
      numberOfDutiesToAnswerTo = @props.numberOfDutiesToAnswerTo
      lines.push(<StatusLine  danger=true message="Vous n'avez pas encore indiqué vos disponilités" />) unless @props.userProvidedHisAvailabilities
      lines.push(<StatusLine  danger=true message="Vous avez #{numberOfDutiesToAnswerTo} demande#{numberOfDutiesToAnswerTo > 1 && 's' || ''} en attente" />) if numberOfDutiesToAnswerTo > 0
      message = <span>Vous avez été choisi <strong>{@props.numberOfDuties}</strong> fois</span>
      lines.push(<StatusLine message={message} />)
      if nextDuty
        message = <span>Prochain rendez-vous : <strong>{nextDuty}</strong></span>
        lines.push(<StatusLine message={message} />)
    else
      lines.push(<StatusLine warning=true message="Ce planning est toujours en cours d'élaboration" />)
    <div className="content status">
      <ul>{lines}</ul>
    </div>

StatusLine = React.createClass
  render: ->
    className = null
    className = 'text-danger'  if @props.danger
    className = 'text-warning' if @props.warning
    <li className={className}>
      {<i className="fa fa-warning" /> if @props.danger or @props.warning}
      {@props.message}
    </li>

NewPlanning = React.createClass
  createPlanning: (e) ->
    e.preventDefault()
    input = @refs.planningName.getDOMNode()
    Meteor.call 'createPlanning', input.value.trim(), (error, slug) ->
      window.location = "/planning/#{slug}/admin"
    input.value = '';
  render: ->
    <div className="col-md-3">
      <div className="background">
        <div className="content">
          Nouveau planning
          <form onSubmit={@createPlanning}>
            <input type="text" ref="planningName" placeholder="Nom ?" className="form-control" />
          </form>
        </div>
      </div>
    </div>

Links = React.createClass
  render: ->
    links = []
    links.push(<Link text="Voir le planning" url="/planning/#{@props.planning.slug}" />) if @props.planning.availabilityEmailSent and @props.userProvidedHisAvailabilities
    links.push(<Link text="Indiquer mes disponilités" url="/planning/#{@props.planning.slug}/presences" />) if @props.planning.availabilityEmailSent
    <div className="content links">
      {links}
    </div>

Link = React.createClass
  render: ->
    <a href={@props.url} className="link-with-arrow">
      {@props.text}
      <i className="fa fa-chevron-right" />
    </a>
