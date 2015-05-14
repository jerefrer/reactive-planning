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
  userAnsweredThisPlanning: ->
    @props.planning.peopleWhoAnswered.indexOf(Meteor.userId()) >= 0
  numberOfDuties: ->
    duties = @props.planning.duties
    sum = 0
    Object.keys(duties).each (dayTaskKey) ->
      duties[dayTaskKey].each (duty) ->
        sum++ if duty._id == Meteor.userId()
    sum
  nextDuty: ->
    duties = @props.planning.duties
    day = @props.planning.days.find (day) ->
      Object.keys(duties).find (dayTaskKey) ->
        dayTaskKey.split(',')[0] == day._id and duties[dayTaskKey].find (duty) -> duty._id == Meteor.userId()
    day and day.name
  render: ->
    nextDuty = @nextDuty()
    colorClass = @userAnsweredThisPlanning() && 'success' || 'danger'
    <div className="row">
      <div className="col-md-4" onClick={@openPlanning}>
        <div className="background bg-#{colorClass} text-#{colorClass}">
          <div className="content">{@props.planning.name}</div>
          </div>
      </div>
      <div className="col-md-5">
        <div className="content status">
          <ul>
            {<li className="text-danger"><i className="fa fa-warning" />{"Vous n'avez pas encore indiqué vos disponilités"}</li> unless @userAnsweredThisPlanning()}
            <li>Vous avez été choisi <strong>{@numberOfDuties()}</strong> fois</li>
            {<li>Prochain rendez-vous : <strong>{nextDuty}</strong></li> if nextDuty}
          </ul>
        </div>
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
