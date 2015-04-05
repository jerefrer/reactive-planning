PlanningsList = React.createClass({
  render: function() {
    var plannings = this.props.plannings.map(function(planning) {
      return <Planning id={planning._id} name={planning.name} slug={planning.slug} />;
    });
    return (
      <div>
        {plannings}
        <NewPlanning />
      </div>
    );
  }
});

var Planning = React.createClass({
  openPlanning: function() {
    window.location = "/planning/" + this.props.slug;
  },
  openPlanningAdmin: function(e) {
    e.stopPropagation();
    window.location = "/planning/" + this.props.slug + "/admin";
  },
  removePlanning: function(e) {
    e.preventDefault();
    e.stopPropagation();
    if (confirm('Êtes-vous sûr ?')) Meteor.call('removePlanning', this.props.id);
  },
  render: function() {
    return (
      <div className="col-md-3" onClick={this.openPlanning}>
        <div className="background">
          <a className="remove fa fa-remove" onClick={this.removePlanning}></a>
          <div className="content">
            {this.props.name}
            <br />
            <a className="btn btn-primary" onClick={this.openPlanningAdmin}>Admin</a>
          </div>
        </div>
      </div>
    );
  }
})

var NewPlanning = React.createClass({
  createPlanning: function(e) {
    e.preventDefault();
    var input = this.refs.planningName.getDOMNode();
    Meteor.call('createPlanning', input.value.trim(), function(error, slug) {
      window.location = "/planning/" + slug + "/admin";
    });
    input.value = '';
  },
  render: function() {
    return (
      <div className="col-md-3">
        <div className="background">
          <div className="content">
            Nouveau planning
            <form onSubmit={this.createPlanning}>
              <input type="text" ref="planningName" placeholder="Nom ?" />
            </form>
          </div>
        </div>
      </div>
    );
  }
})
