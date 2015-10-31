@Dashboard = React.createClass
  render: ->
    plannings = sortPlannings(@props.plannings).map (planning) ->
      <Planning planning={planning} />
    <div className="dashboard">
      {plannings}
    </div>

Planning = React.createClass
  render: ->
    <AskForAvailabilities planning={@props.planning} />

AskForAvailabilities = React.createClass
  userProvidedHisAvailabilities: ->
    @props.planning.peopleWhoAnswered.indexOf(Meteor.userId()) >= 0
  goToAvailabilitiesPage: ->
    window.location = "/planning/#{@props.planning.slug}/presences"
  statusBar: ->
    if @userProvidedHisAvailabilities()
      <StatusBar color='green' />
    else
      <StatusBar color='yellow' />
  content: ->
    if @userProvidedHisAvailabilities()
      <div className="status">
        <strong>Modifier mes disponibilités</strong>
      </div>
    else
      <div className="status alerte">
        <i className="fa fa-exclamation-circle" />
        <span>
          {"Vous n'avez pas encore indiqué"}
          <strong> vos disponilités</strong>
        </span>
      </div>
  render: ->
    <div className="planning hoverable" onClick={@goToAvailabilitiesPage}>
      {@statusBar()}
      <div className="content">
        <div className="left">
          <div className="name">{@props.planning.name}</div>
          {@content()}
        </div>
        <div className="links">
          <a className="single-link">
            <i className="fa fa-chevron-right"></i>
          </a>
        </div>
      </div>
    </div>

StatusBar = React.createClass
  render: ->
    className = "status-bar "
    className += @props.color
    <div className={className}></div>
