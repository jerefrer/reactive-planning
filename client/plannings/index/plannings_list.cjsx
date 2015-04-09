@PlanningsList = React.createClass
  render: ->
    plannings = @props.plannings.map (planning) ->
      <Planning id={planning._id} name={planning.name} slug={planning.slug} />
    <div>
      {plannings}
      <NewPlanning />
    </div>

Planning = React.createClass
  openPlanning: ->
    window.location = "/planning/" + @props.slug
  openPlanningAdmin: (e) ->
    e.stopPropagation()
    window.location = "/planning/" + @props.slug + "/admin"
  removePlanning: (e) ->
    e.preventDefault()
    e.stopPropagation()
    Meteor.call('removePlanning', @props.id) if confirm('Êtes-vous sûr ?')
  render: ->
    <div className="col-md-3" onClick={@openPlanning}>
      <div className="background">
        <a className="remove fa fa-remove" onClick={@removePlanning}></a>
        <div className="content">
          {@props.name}
          <br />
          <a className="btn btn-primary" onClick={@openPlanningAdmin}>Admin</a>
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
            <input type="text" ref="planningName" placeholder="Nom ?" />
          </form>
        </div>
      </div>
    </div>
