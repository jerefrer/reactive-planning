Plannings = new Meteor.Collection('plannings');
SoundsToPlay = new Meteor.Collection('sounds_to_play');

eachDuty = function(planningId, callback) {
  var planning = Plannings.findOne({_id: planningId});
  Object.keys(planning.duties).each(function(key) {
    var dayId  = key.split(',')[0],
        taskId = key.split(',')[1],
        day  = planning.days.find({_id: dayId}),
        task = planning.tasks.find({_id: taskId}),
        people = planning.duties[dayId+','+taskId];
    people.each(function(person) {
      callback(planning, day, task, person);
    });
  });
}

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
  },
  sendEmailNotifications: function(planningId) {
    this.unblock();

    // var person = { name: 'Jérémy', phone: '+33628055409'},
    //     task = { name: "Médiateur, response d'équipe", short_name: 'Médiateur' },
    //     day = { name: 'Samedi 28 Septembre 2015' },
    //     planning = Plannings.findOne({_id: planningId});

    eachDuty(planningId, function(planning, day, task, person) {
      Email.send({
        to: person.email,
        from: 'admin@planning-24.com',
        subject: "Êtes-vous disponible ?",
        text: 'Bonjour ' + person.name + ",<br />" +
              'Tu as été désigné pour \"' + task.short_name + '\" le ' + day.name + ".<br />" +
              "<a href='" + Meteor.absoluteUrl('planning/' + planning.slug + '/confirm/' + day._id + '/' + task._id + '/' + person._id) + "'>Clique ici pour confirmer</a><br />" +
              "<a href='" + Meteor.absoluteUrl('planning/' + planning.slug + '/decline/' + day._id + '/' + task._id + '/' + person._id) + "'>Clique ici pour décliner</a><br />"
      });
    });
  },
  sendSMSNotifications: function(planningId) {
    var person = { name: 'Jérémy', phone: '+33628055409'},
        task = { name: "Médiateur, response d'équipe", short_name: 'Médiateur' },
        day = { name: 'Samedi 28 Septembre 2015' },
        ACCOUNT_SID = 'AC3869695257d0b4105a8286c9bf868c24',
        AUTH_TOKEN = 'f4bd037ce0f2f7e9338b819af6aae578';
        twilio_number = '+15005550006';
        twilio = Twilio(ACCOUNT_SID, AUTH_TOKEN);
    eachDuty(planningId, function(planning, day, task, person) {
      twilio.sendSms({
        to: person.phone,
        from: twilio_number,
        body: 'Bonjour ' + person.name + ",\n" +
              'Tu as été désigné pour \"' + task.short_name + '\" le ' + day.name + ".\n" +
              "1 pour confirmer,\n" +
              "0 pour décliner."
      }, function(err, responseData) {
      });
    });
  },
  answerNotification: function(planningSlug, dayId, taskId, personId, positive) {
    var planning = Plannings.findOne({slug: planningSlug});
    var duties = planning.duties;
    var key = dayId+','+taskId;
    var people = duties[key];
    var person = people.find({_id: personId});
    var set = {};
    person.positive = positive;
    set['duties.' + key] = people;
    Plannings.update(planning._id, {$set: set});
    SoundsToPlay.remove({});
    SoundsToPlay.insert({filename: positive ? '/success.ogg' : '/failure.ogg'});
  },
  cycleStatus: function(planningId, dayId, taskId, personId) {
    var planning = Plannings.findOne({_id: planningId});
    var duties = planning.duties;
    var key = dayId+','+taskId;
    var people = duties[key];
    var person = people.find({_id: personId});
    var set = {};
    if      (person.positive === undefined) person.positive = true;
    else if (person.positive === true)      person.positive = false;
    else if (person.positive === false)     delete person.positive;
    set['duties.' + key] = people;
    Plannings.update(planning._id, {$set: set});
  }
});

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
      {_id: guid(), name: "Anne",   email: 'anne.benson@gmail.com'},
      {_id: guid(), name: "Jérémy", email: 'frere.jeremy@gmail.com'}
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

Meteor.publish("plannings",      function() { return Plannings.find();    });
Meteor.publish("sounds_to_play", function() { return SoundsToPlay.find(); });
