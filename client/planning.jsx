Plannings = new Meteor.Collection('plannings');
SoundsToPlay = new Meteor.Collection('sounds_to_play');

var DragDropMixin = ReactDND.DragDropMixin,
    ItemTypes = { PERSON: 'person' };

Scheduler = React.createClass({
  mixins: [ReactMeteor.Mixin],
  startMeteorSubscriptions: function() {
    Meteor.subscribe('users');
    Meteor.subscribe('plannings');
    Meteor.subscribe('sounds_to_play');
  },
  getMeteorState: function() {
    var state = {
      days: [],
      tasks: [],
      duties: [],
      people: Meteor.users.find().fetch()
    }
    if (this.props.planning) {
      state.days   = this.props.planning.days
      state.tasks  = this.props.planning.tasks
      state.duties = this.props.planning.duties
    }
    return state;
  },
  clearDuties: function(e) {
    e.preventDefault();
    Meteor.call('clearDuties', this.props.planning._id);
  },
  sendNotifications: function(e) {
    e.preventDefault();
    Meteor.call('sendEmailNotifications', this.props.planning._id);
  },
  render: function() {
    var sound_to_play = SoundsToPlay.find().fetch()[0];
    if (sound_to_play) {
      playedSounds = Session.get('playedSounds');
      if (playedSounds) {
        if (playedSounds.indexOf(sound_to_play._id) < 0) {
          var sound = new buzz.sound(sound_to_play.filename);
          sound.play();
          playedSounds.push(sound_to_play._id);
          Session.setPersistent('playedSounds', playedSounds);
        }
      } else {
        Session.setPersistent('playedSounds', [sound_to_play._id]);
      }
    }
    return (
      <div className="row">
        <div className="col-md-9">
          <h2>
            Planning{' - '}
            <button className="btn btn-danger" onClick={this.clearDuties}>Tout effacer</button>{' - '}
            <button className="btn btn-primary" onClick={this.sendNotifications}>Envoyer les E-mails</button>
          </h2>
          <Schedule planningId={this.props.planning._id} tasks={this.state.tasks} days={this.state.days} duties={this.state.duties} />
        </div>
        <div className="col-md-3">
          <h2>Bénévoles</h2>
          <PeopleList people={this.state.people} />
        </div>
      </div>
    );
  }
});

var Schedule = React.createClass({
  render: function() {
    var lines = []
    var tasks = this.props.tasks;
    var duties = this.props.duties;
    var planningId = this.props.planningId;
    this.props.days.forEach(function(day) {
      lines.push(<ScheduleLine planningId={planningId} tasks={tasks} day={day} duties={duties} />);
    });
    return (
      <table id="schedule" className="table table-striped table-bordered">
        <thead>
          <ScheduleHeader tasks={tasks} />
        </thead>
        <tbody>
          {lines}
          <tr>
            <td><AddDayCell planningId={planningId} onAddDay={this.handleAddDay} /></td>
            <td colSpan="5000"></td>
          </tr>
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
    var duties = this.props.duties;
    var cells = [];
    this.props.tasks.forEach(function(task) {
      cells.push(<ScheduleCell planningId={planningId} day={day} task={task} duties={duties} />);
    });
    return (
      <tr>
        <td><DayName planningId={planningId} day={day} /></td>
        {cells}
      </tr>
    );
  }
});

var DayName = React.createClass({
  getInitialState: function() {
    return {formIsVisible: false};
  },
  showForm: function() {
    this.setState({formIsVisible: true});
  },
  hideForm: function() {
    this.setState({formIsVisible: false});
  },
  updateDayName: function(dayName) {
    this.hideForm();
    Meteor.call('updateDayName', this.props.planningId, this.props.day, dayName);
  },
  render: function() {
    if (this.state.formIsVisible)
      return <DayForm originalValue={this.props.day.name} onSubmit={this.updateDayName} onCancel={this.hideForm} />;
    else
      return <strong onClick={this.showForm} title="Cliquez pour modifier">{this.props.day.name}</strong>;
  }
})

var ScheduleCell = React.createClass({
  handlePersonDrop: function(person) {
    var cell = person.scheduleCell;
    person.scheduleCell = null; // Remove the schedule cell so it's not serialized to be sent to Meteor
    Meteor.call('addPerson', this.props.planningId, this.props.day, this.props.task, person);
    if (cell)
      Meteor.call('removePerson', this.props.planningId, cell.props.day, cell.props.task, person);
  },
  removePerson: function(person)  {
    person.scheduleCell = null; // Remove the schedule cell so it's not serialized to be sent to Meteor
    Meteor.call('removePerson', this.props.planningId, this.props.day, this.props.task, person);
  },
  mixins: [DragDropMixin],
  statics: {
    configureDragDrop(register) {
      register(ItemTypes.PERSON, {
        dropTarget: {
          acceptDrop(component, person) {
            component.handlePersonDrop(person);
          }
        }
      });
    }
  },
  render: function() {
    var self = this;
    var removePerson = this.removePerson;
    var peopleList = this.props.duties[k(this.props.day)+','+k(this.props.task)];
    var people;
    if (peopleList) {
      people = peopleList.map(function(personObject) {
        return <Person person={personObject} scheduleCell={self} onThrowAway={removePerson}/>;
      });
    }
    var dropState = this.getDropState(ItemTypes.PERSON);
    var className = '';
    if (dropState.isHovering) className = 'hover'
    return <td {...this.dropTargetFor(ItemTypes.PERSON)} className={className}>{people}</td>;
  }
});

var Person = React.createClass({
  mixins: [DragDropMixin],
  statics: {
    configureDragDrop(register) {
      register(ItemTypes.PERSON, {
        dragSource: {
          beginDrag(component) {
            var person = component.props.person;
            person.scheduleCell = component.props.scheduleCell; // DND only passed the JS object, not the React one, so we have to explicitly set scheduleCell on the JS object
            return {
              item: person
            };
          },
          endDrag(component, effect) {
            if (!effect) // If throwing away
              if (component.props.onThrowAway)
                component.props.onThrowAway(component.props.person);
          }
        }
      });
    }
  },
  getPerson: function() {
    return Meteor.users.findOne({_id: this.props.person._id});
  },
  cycleStatus: function() {
    var cell = this.props.scheduleCell;
    Meteor.call('cycleStatus', cell.props.planningId, cell.props.day._id, cell.props.task._id, this.props.person._id);
  },
  render: function() {
    var that = this;
    var person = this.getPerson();
    if (person) {
      var positive = this.props.person.positive,
          className = 'alert ';
      if (positive === undefined)  className += 'neutral background-fade';
      else if (positive === true)  className += 'good    background-fade hvr-wobble-vertical';
      else if (positive === false) className += 'bad     background-fade hvr-wobble-horizontal';
      return (
        <div className={className}
             {...that.dragSourceFor(ItemTypes.PERSON)}
             onDoubleClick={this.cycleStatus} >
          {person.username}
        </div>
       );
    } else return null;
  }
})

var AddDayCell = React.createClass({
  getInitialState: function() {
    return {formIsVisible: false};
  },
  showForm: function() {
    this.setState({formIsVisible: true});
  },
  hideForm: function() {
    this.setState({formIsVisible: false});
  },
  addDay: function(dayName) {
    this.hideForm();
    Meteor.call('addDay', this.props.planningId, dayName);
  },
  render: function() {
    if (this.state.formIsVisible)
      return <DayForm onSubmit={this.addDay} onCancel={this.hideForm} />;
    else
      return <a href="#" onClick={this.showForm}>Ajouter un jour</a>;
  }
})

var DayForm = React.createClass({
  componentDidMount: function() {
    domNode = this.refs.dayName.getDOMNode()
    if (this.props.originalValue)
      domNode.value = this.props.originalValue;
    domNode.select();
  },
  handleSubmit: function(e) {
    e.preventDefault();
    var dayName = this.refs.dayName.getDOMNode().value.trim();
    this.props.onSubmit(dayName);
    this.refs.dayName.getDOMNode().value = '';
  },
  render: function() {
    return (
      <div>
        <form onSubmit={this.handleSubmit}>
          <input className="form-control" ref="dayName" />
        </form>
        <a href="#" onClick={this.props.onCancel} className="pull-right">Annuler</a>
      </div>
    );
  }
})

var PeopleList = React.createClass({
  filterBySearchTerm: function(term) {
    this.setState({
      people: this.props.people.findAll({
        name: new RegExp(term, 'i')
      })
    });
  },
  render: function() {
    var people = this.state ? this.state.people : this.props.people; // Hack, seems that getInitialState gets called the first time when everything is empty, and not the second time when it's filled
    var people_list = people.map(function(person) {
      return <li><Person person={person}/></li>;
    });
    return (
      <div id="people-list">
        <PeopleFilters onChange={this.filterBySearchTerm} />
        <ul className="list-unstyled">{people_list}</ul>
      </div>
    );
  }
});

var PeopleFilters = React.createClass({
  handleChange: function() {
    this.props.onChange(this.refs.name.getDOMNode().value.trim());
  },
  render: function() {
    return (<div className="form-group form-inline">
      <label className="control-label">Nom</label>
      <input type="text" ref="name" onChange={this.handleChange} className="form-control" />
    </div>);
  }
});
