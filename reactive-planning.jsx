Plannings = new Meteor.Collection('plannings');

if (Meteor.isServer) {
  Meteor.methods({
    addDay: function(planningId, dayName) {
      var planning = Plannings.findOne({_id: planningId});
      var days = planning.days;
      days.push({_id: guid(), name: dayName});
      Plannings.update(planning._id, {$set: {days: days}});
    },
    updateDayName: function(planningId, day, newName) {
      Plannings.update(
       { _id: planningId, days: { $elemMatch: {_id: day._id} } },
       { $set: { "days.$.name" : newName } }
      )
    },
    addPerson: function(planningId, day, task, person) {
      var planning = Plannings.findOne({_id: planningId});
      var duties = planning.duties;
      var people = getPeople(duties, day, task);
      debugger;
      if (!people) people = [];
      if (!people.find({_id: person._id}))
        people.push(person);
        var set = {};
        set['duties.' + k(day) + ',' + k(task)] = people;
        Plannings.update(planning._id, {$set: set});
    },
    removePerson: function(planningId, day, task, person) {
      var planning = Plannings.findOne({_id: planningId});
      var duties = planning.duties;
      var people = getPeople(duties, day, task);
      people.remove({_id: person._id});
      var set = {};
      set['duties.' + k(day) + ',' + k(task)] = people;
      Plannings.update(planning._id, {$set: set});
    },
    clearDuties: function(planningId) {
      Plannings.update(planningId, {$set: {duties: {}}})
    }
  });
}

var DragDropMixin = ReactDND.DragDropMixin,
    ItemTypes = { PERSON: 'person' };

var Scheduler = React.createClass({
  mixins: [ReactMeteor.Mixin],
  startMeteorSubscriptions: function() {
    Meteor.subscribe('plannings');
  },
  getMeteorState: function() {
    if (this.props.planning)
      return {
        days: this.props.planning.days,
        tasks: this.props.planning.tasks,
        people: this.props.planning.people,
        duties: this.props.planning.duties
      };
    else
      return {
        days: [],
        tasks: [],
        people: [],
        duties: []
      }
  },
  clearDuties: function(e) {
    e.preventDefault();
    Meteor.call('clearDuties', this.props.planning._id);
  },
  render: function() {
    return (
      <div className="row">
        <div className="col-md-9">
          <h2>
            Planning - <a href="#" className="small" onClick={this.clearDuties}>Tout effacer</a>
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
      <table className="table table-striped table-bordered">
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
    var peopleList = getPeople(this.props.duties, this.props.day, this.props.task);
    var people = '';
    var removePerson = this.removePerson;
    if (peopleList) {
      people = peopleList.map(function(person) {
        return <Person person={person} scheduleCell={self} onThrowAway={removePerson}/>;
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
  render: function() {
    return (
      <div className="alert alert-info text-center"
           {...this.dragSourceFor(ItemTypes.PERSON)} >
        {this.props.person.name}
      </div>
     );
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
    var people_lis = people.map(function(person) {
      return <li><Person person={person}/></li>;
    });
    return (<div>
      <PeopleFilters onChange={this.filterBySearchTerm} />
      <ul className="list-unstyled">{people_lis}</ul>
    </div>);
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

// On server startup, create some players if the database is empty.
if (Meteor.isServer) {
  Meteor.startup(function () {
    if (!Plannings.findOne({name: 'Périgueux'})) {
      var days = [
        {_id: guid(), name: "Samedi 7 Mars 2015"},
        {_id: guid(), name: "Dimanche 8 Mars 2015"},
        {_id: guid(), name: "Samedi 14 Mars 2015"},
        {_id: guid(), name: "Dimanche 15 Mars 2015"}
      ];
      var tasks = [
        {_id: guid(), name: "Banque alimentaire"},
        {_id: guid(), name: "Médiateur, responsable d'équipe"},
        {_id: guid(), name: "Chercher pain"}
      ];
      var people = [
        {_id: guid(), name: "Anne"},
        {_id: guid(), name: "Jérémy"}
      ];
      Plannings.insert({
        name: 'Périgueux',
        slug: 'perigueux',
        days: days,
        tasks: tasks,
        people: people,
        duties: {}
      })
    }
  });

  Meteor.publish("plannings", function() {
    return Plannings.find();
  });
}

Router.configure({
  layoutTemplate: 'Layout',
  loadingTemplate: 'Loading',
  notFoundTemplate: 'NotFound',
});
Router.onBeforeAction('loading');

Router.route('Home', { path: '/' });
Router.route('Plannings', {
  path: '/plannings',
  waitOn: function () {
    return Meteor.subscribe('plannings');
  },
  data: {
    plannings: function() { return Plannings.find().fetch() }
  }
});
Router.route('Planning', {
  path: '/planning/:slug',
  waitOn: function () {
    return Meteor.subscribe('plannings');
  },
  action: function () {
    var planning = Plannings.findOne({slug: this.params.slug});
    Session.set('currentPlanning', planning);
    this.render('Planning', {planning: planning});
    setTimeout(function() {
      React.render(
        <Scheduler planning={planning} />,
        document.getElementById('planning')
      );
    }, 100);
  }
});

var k = function(object) {
  var key = object._id;
  return key;
}

var guid = function() {
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1);
  }
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
    s4() + '-' + s4() + s4() + s4();
}

var getPeople = function(duties, day, task) {
  return duties[k(day)+','+k(task)];
}
