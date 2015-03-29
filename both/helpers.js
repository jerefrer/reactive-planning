k = function(object) {
  var key = object._id;
  return key;
}

guid = function() {
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1);
  }
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
    s4() + '-' + s4() + s4() + s4();
}

getPeople = function(object, day, task) {
  var people = object[k(day)+','+k(task)];
  if (people) {
    var peopleIds = people.map(function(person) { return person._id; });
    return Meteor.users.find({_id: {$in: peopleIds}}).fetch();
  }
  else return [];
}
