UserPlanning = React.createClass({
  mixins: [ReactMeteor.Mixin],
  startMeteorSubscriptions: function() {
    Meteor.subscribe('plannings');
  },
  getMeteorState: function() {
    if (this.props.planning)
      return {
        days: this.props.planning.days,
        presences: this.props.planning.presences
      };
    else
      return {
        days: [],
        people: [],
        presences: []
      }
  },
  render: function() {
    return (
      <div className="userPlanning">
        <h2>Planning {planning.name}</h2>
        <div className="row">
          <div className="col-md-6">
            <Schedule planningId={this.props.planning._id} days={this.state.days} presences={this.state.presences} />
          </div>
          <div className="col-md-6 jumbotron">
            Merci de cochez les cases des jours où vous êtes disponible.
          </div>
        </div>
      </div>
    );
  }
});

var Schedule = React.createClass({
  render: function() {
    var lines = []
    var presences = this.props.presences;
    var planningId = this.props.planningId;
    this.props.days.forEach(function(day) {
      lines.push(<ScheduleLine planningId={planningId} day={day} presences={presences} />);
    });
    return (
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
    );
  }
});

var ScheduleHeader = React.createClass({
  render: function() {
    var tasks = [];
    this.props.tasks.forEach(function(task) {
      tasks.push(<td><strong>{task.name}</strong></td>);
    });
    return (
      <tr>
        <td></td>
        {tasks}
      </tr>
    );
  }
});

var ScheduleLine = React.createClass({
  render: function() {
    var planningId = this.props.planningId;
    var day = this.props.day;
    var presences = this.props.presences;
    var cells = [];
    cells.push(<ScheduleCell planningId={planningId} day={day} presences={presences} />);
    return (
      <tr>
        <th>{this.props.day.name}</th>
        {cells}
      </tr>
    );
  }
});

var ScheduleCell = React.createClass({
  togglePresence: function() {
    Meteor.call('togglePresence', this.props.planningId, this.props.day._id, Meteor.userId());
  },
  render: function() {
    var peopleList = this.props.presences[this.props.day._id];
    var present = peopleList && peopleList.find({_id: Meteor.userId()})
    var className = (present) ? "fa fa-check-square-o text-success" : "fa fa-square-o text-muted";
    return (
      <td className="text-center" onClick={this.togglePresence}>
        <i className={className} />
      </td>
    );
  }
});
