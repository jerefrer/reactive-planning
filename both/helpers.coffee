@k = (object) ->
  object._id

@guid = ->
  s4 = ->
    Math.floor((1 + Math.random()) * 0x10000).toString(16).substring 1
  s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4()

@getPeople = (object, day, task) ->
  people = object[k(day) + ',' + k(task)]
  if people
    peopleIds = people.map (person) ->
      person._id
    Meteor.users.find(_id: $in: peopleIds).fetch()
  else
    []
