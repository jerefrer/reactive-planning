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

@isAdmin = ->
  Roles.userIsInRole(Meteor.user(), 'admin')

@displayName = (user) ->
  if user.profile.firstname and user.profile.lastname
    "#{user.profile.firstname.capitalize()} #{user.profile.lastname[0].toUpperCase()}."
  else if user.profile.firstname
    user.profile.firstname.capitalize()
  else if user.profile.lastname
    user.profile.lastname.capitalize()

@unavailableTheWholeMonth = (planning, user) ->
  planning.unavailableTheWholeMonth.indexOf(user._id) >= 0
