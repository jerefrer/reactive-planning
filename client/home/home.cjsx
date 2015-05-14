userAnsweredPlanning = (planning) ->
  planning.peopleWhoAnswered.indexOf(Meteor.userId()) >= 0

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
  anyEmailSentAlready: ->
    duties = @props.planning.duties
    Object.keys(duties).any (dayTaskKey) ->
      duties[dayTaskKey].any (duty) ->
        duty.emailSent == undefined
  hasError: (numberOfDutiesToAnswerTo) ->
    userAnsweredPlanning(@props.planning) || (numberOfDutiesToAnswerTo > 0)
  colorClass: (numberOfDutiesToAnswerTo) ->
    if @anyEmailSentAlready()
      @hasError(numberOfDutiesToAnswerTo) && 'danger' || 'success'
    else
      'warning'
  render: ->
    anyEmailSentAlready = @anyEmailSentAlready()
    userDuties = @userDuties()
    numberOfDutiesToAnswerTo = @numberOfDutiesToAnswerTo(userDuties)
    colorClass = @colorClass(anyEmailSentAlready, numberOfDutiesToAnswerTo)
    <div className="row">
      <div className="col-md-4" onClick={@openPlanning}>
        <div className="background bg-#{colorClass} text-#{colorClass}">
          <div className="content">{@props.planning.name}</div>
          </div>
      </div>
      <div className="col-md-5">
        <Status planning={@props.planning} anyEmailSentAlready={anyEmailSentAlready} numberOfDuties={userDuties.length} numberOfDutiesToAnswerTo={numberOfDutiesToAnswerTo}/>
      </div>
      <div className="col-md-3">
        <div className="content links">
          <a href={"/planning/" + @props.planning.slug} className="link-with-arrow">
            Voir le planning
            <i className="fa fa-chevron-right" />
          </a>
          <br />
          <a href={"/planning/" + @props.planning.slug + "/presences"} className="link-with-arrow">
            Indiquer mes disponilités
            <i className="fa fa-chevron-right" />
          </a>
        </div>
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
    nextDuty = @nextDuty()
    numberOfDutiesToAnswerTo = @props.numberOfDutiesToAnswerTo
    lines = []
    lines.push(<StatusLine warning=true message="Ce planning est toujours en cours d'élaboration" />) unless @props.anyEmailSentAlready
    lines.push(<StatusLine  danger=true message="Vous n'avez pas encore indiqué vos disponilités" />) unless userAnsweredPlanning(@props.planning)
    lines.push(<StatusLine  danger=true message="Vous avez #{numberOfDutiesToAnswerTo} demande#{numberOfDutiesToAnswerTo > 1 && 's' || ''} en attente" />) if numberOfDutiesToAnswerTo > 0
    if @props.anyEmailSentAlready
      message = <span>Vous avez été choisi <strong>{@props.numberOfDuties}</strong> fois</span>
      lines.push(<StatusLine message={message} />)
    if nextDuty
      message = <span>Prochain rendez-vous : <strong>{nextDuty}</strong></span>
      lines.push(<StatusLine message={message} />)
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
