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

getPeople = function(duties, day, task) {
  return duties[k(day)+','+k(task)];
}
