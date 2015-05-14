@UsersPresence = React.createClass
  mixins: [ReactMeteor.Mixin]
  startMeteorSubscriptions: ->
    Meteor.subscribe('users')
    Meteor.subscribe('plannings')
  getMeteorState: ->
    if @props.planning
      {
        days: @props.planning.days
        people: Meteor.users.find().fetch()
        presences: @props.planning.presences
      }
    else
      {
        days: []
        people: []
        presences: []
      }
  render: ->
    <div className="usersPresence">
      <h2>Planning {planning.name}</h2>
      <Schedule planningId={@props.planning._id} days={@state.days} people={@state.people} presences={@state.presences} />
    </div>

Schedule = React.createClass
  filterBySearchTerm: (term) ->
    @setState people: @props.people.findAll (user) ->
      getSlug(user.username).fuzzy getSlug(term)
  render: ->
    people = if @state then @state.people else @props.people
    # Hack, seems that getInitialState gets called the first time when everything is empty, and not the second time when it's filled
    lines = people.map (person) =>
      <ScheduleLine planningId={@props.planningId} days={@props.days} person={person} presences={@props.presences} />
    <table id="schedule" className="table table-striped table-bordered">
      <thead>
        <ScheduleHeader days={@props.days} onFilterChange={@filterBySearchTerm} />
      </thead>
      <tbody>
        {lines}
      </tbody>
    </table>

ScheduleHeader = React.createClass
  render: ->
    days = @props.days.map (day) ->
      <th><strong>{day.name}</strong></th>
    <tr>
      <th>
        <PeopleFilter people={@props.people} onChange={@props.onFilterChange} />
      </th>
      {days}
    </tr>

PeopleFilter = React.createClass
  handleChange: ->
    @props.onChange @refs.name.getDOMNode().value.trim()
  render: ->
    <div className="form-group form-inline">
      <input type="text" ref="name" onChange={@handleChange} className="form-control" placeholder="Nom" />
    </div>

ScheduleLine = React.createClass
  render: ->
    days = @props.days.map (day) =>
      <ScheduleCell planningId={@props.planningId} day={day} person={@props.person} presences={@props.presences} />
    <tr>
      <th>{@props.person.username}</th>
      {days}
    </tr>

ScheduleCell = React.createClass
  togglePresence: ->
    Meteor.call('togglePresence', @props.planningId, @props.day._id, @props.person._id, true)
  render: ->
    peopleList = @props.presences[@props.day._id]
    present = peopleList && peopleList.find({_id: @props.person._id})
    className = if present then "fa fa-check-square-o text-success" else "fa fa-square-o text-muted"
    <td className="text-center" onClick={@togglePresence}>
      <i className={className} />
    </td>
