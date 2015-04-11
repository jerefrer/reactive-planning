@UserPresence = React.createClass
  mixins: [ReactMeteor.Mixin]
  startMeteorSubscriptions: ->
    Meteor.subscribe('users')
    Meteor.subscribe('plannings')
  getMeteorState: ->
    Meteor.users.find().fetch() # Fixes undisplayed first click result
    if @props.planning
      {
        days: @props.planning.days
        presences: @props.planning.presences
      }
    else
      {
        days: []
        presences: []
      }
  render: ->
    <div className="userPresence">
      <h2>Planning {planning.name}</h2>
      <div className="row">
        <div className="col-md-6">
          <Schedule planningId={@props.planning._id} days={@state.days} presences={@state.presences} />
        </div>
        <div className="col-md-6 jumbotron">
          Merci de cochez les cases des jours où vous êtes disponible.
        </div>
      </div>
    </div>

Schedule = React.createClass
  render: ->
    lines = @props.days.map (day) =>
      <ScheduleLine planningId={@props.planningId} day={day} presences={@props.presences} />
    <table id="schedule" className="table table-striped table-bordered">
      <thead>
        <tr>
          <th>Jour</th>
          <th className="text-center">Présence</th>
        </tr>
      </thead>
      <tbody>
        {lines}
      </tbody>
    </table>

ScheduleHeader = React.createClass
  render: ->
    tasks = @props.tasks.map (task) ->
      <td><strong>{task.name}</strong></td>
    <tr>
      <td></td>
      {tasks}
    </tr>

ScheduleLine = React.createClass
  render: ->
    <tr>
      <th>{@props.day.name}</th>
      <ScheduleCell planningId={@props.planningId} day={@props.day} presences={@props.presences} />
    </tr>

ScheduleCell = React.createClass
  togglePresence: ->
    Meteor.call('togglePresence', @props.planningId, @props.day._id, Meteor.userId())
  render: ->
    peopleList = @props.presences[@props.day._id]
    present = peopleList && peopleList.find({_id: Meteor.userId()})
    className = if present then "fa fa-check-square-o text-success" else "fa fa-square-o text-muted"
    <td className="text-center" onClick={@togglePresence}>
      <i className={className} />
    </td>
