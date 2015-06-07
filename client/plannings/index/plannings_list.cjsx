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
      <div className="background hoverable">
        <a className="remove fa fa-remove" onClick={@removePlanning}></a>
        <div className="content">{@props.name}</div>
      </div>
    </div>

NewPlanning = React.createClass
  createPlanning: (e) ->
    e.preventDefault()
    monthInput = @refs.planningMonth.getDOMNode()
    yearInput = @refs.planningYear.getDOMNode()
    Meteor.call 'createPlanning', monthInput.value, yearInput.value, (error, slug) ->
      window.location = "/planning/#{slug}/admin"
  render: ->
    nextMonth = moment().add('month', 1)
    <div className="col-md-3">
      <div className="background">
        <div className="content">
          <form onSubmit={@createPlanning}>
            <div className="form-group form-inline">
              <select ref="planningMonth" className="form-control">
                <option value="0" selected={nextMonth.month() == 0}>Janvier</option>
                <option value="1" selected={nextMonth.month() == 1}>Février</option>
                <option value="2" selected={nextMonth.month() == 2}>Mars</option>
                <option value="3" selected={nextMonth.month() == 3}>Avril</option>
                <option value="4" selected={nextMonth.month() == 4}>Mai</option>
                <option value="5" selected={nextMonth.month() == 5}>Juin</option>
                <option value="6" selected={nextMonth.month() == 6}>Juillet</option>
                <option value="7" selected={nextMonth.month() == 7}>Août</option>
                <option value="8" selected={nextMonth.month() == 8}>Septembre</option>
                <option value="9" selected={nextMonth.month() == 9}>Octobre</option>
                <option value="10" selected={nextMonth.month() == 10}>Novembre</option>
                <option value="11" selected={nextMonth.month() == 11}>Décembre</option>
              </select>
              <select ref="planningYear" className="form-control">
                <option value={nextMonth.year()} selected="selected">{nextMonth.year()}</option>
                <option value={nextMonth.year() + 1}>{nextMonth.year() + 1}</option>
              </select>
            </div>
            <button type="submit" className="btn btn-primary">Créer un nouveau planning</button>
          </form>
        </div>
      </div>
    </div>
