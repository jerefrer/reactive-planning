@PlanningsList = React.createClass
  render: ->
    plannings = @props.plannings.map (planning) ->
      <Planning planning={planning} name={planning.name} slug={planning.slug} />
    <div>
      {plannings}
      <NewPlanning />
    </div>

Planning = React.createClass
  openPlanningAdmin: (e) ->
    window.location = "/planning/" + @props.slug + "/admin"
  removePlanning: (e) ->
    e.preventDefault()
    e.stopPropagation()
    Meteor.call('removePlanning', @props.planning._id) if confirm('Êtes-vous sûr ?')
  render: ->
    <div className="col-md-3" onClick={@openPlanningAdmin}>
      <div className="background">
        <a className="remove fa fa-remove" onClick={@removePlanning}></a>
        <div className="content">{@props.name}</div>
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
