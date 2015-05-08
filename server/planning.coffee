Plannings = new (Meteor.Collection)('plannings')
SoundsToPlay = new (Meteor.Collection)('sounds_to_play')

eachDuty = (planningId, callback) ->
  planning = Plannings.findOne(_id: planningId)
  Object.keys(planning.duties).each (key) ->
    dayId = key.split(',')[0]
    taskId = key.split(',')[1]
    day = planning.days.find(_id: dayId)
    task = planning.tasks.find(_id: taskId)
    people = planning.duties[dayId + ',' + taskId]
    people.each (personObject) ->
      person = Meteor.users.findOne(_id: personObject._id)
      callback planning, day, task, person

Meteor.methods
  createPlanning: (name, days) ->
    if !days
      days = []
    tasks = [{_id: guid(), name: 'Banque alimentaire'},
             {_id: guid(), name: 'Médiateur, responsable d\'équipe' },
             {_id: guid(), name: 'Chercher pain'}
             {_id: guid(), name: 'Ramasse Carrefour Market'},
             {_id: guid(), name: 'Préparer soupe'},
             {_id: guid(), name: 'Amener soupe'},
             {_id: guid(), name: 'Camion'},
             {_id: guid(), name: 'Chargement'},
             {_id: guid(), name: 'Accueil & Distribution'},
             {_id: guid(), name: 'Fourniture comptoir'},
             {_id: guid(), name: 'Servir café & soupe'},
             {_id: guid(), name: 'Déchargement & Vaisselle local'},
             {_id: guid(), name: 'Suppléants'}]
    slug = getSlug(name)
    Plannings.insert
      name: name
      slug: slug
      days: days
      tasks: tasks
      presences: {}
      duties: {}
    slug
  removePlanning: (planningId) ->
    Plannings.remove planningId
  addDay: (planningId, dayName) ->
    planning = Plannings.findOne(_id: planningId)
    days = planning.days
    days.push
      _id: guid()
      name: dayName
    Plannings.update planning._id, $set: days: days
  updateDayName: (planningId, day, newName) ->
    Plannings.update {
      _id: planningId
      days: $elemMatch: _id: day._id
    }, $set: 'days.$.name': newName
  addPerson: (planningId, day, task, person) ->
    planning = Plannings.findOne(_id: planningId)
    duties = planning.duties
    people = duties[day._id + ',' + task._id] || []
    if !people.find(_id: person._id)
      people.push _id: person._id
      set = {}
      set['duties.' + day._id + ',' + task._id] = people
      Plannings.update planning._id, $set: set
  removePerson: (planningId, day, task, person) ->
    planning = Plannings.findOne(_id: planningId)
    duties = planning.duties
    people = duties[day._id + ',' + task._id]
    people.remove _id: person._id
    set = {}
    set['duties.' + day._id + ',' + task._id] = people
    Plannings.update planning._id, $set: set
  clearDuties: (planningId) ->
    Plannings.update planningId, $set: duties: {}
  sendEmailNotifications: (planningId) ->
    @unblock()
    options =
      apiKey: 'key-53e598497990b587981fb538556d929e'
      domain: 'sandboxcca7022b53aa489587e322ab0380c2ae.mailgun.org'
    mailgun = new Mailgun(options)
    eachDuty planningId, (planning, day, task, person) ->
      mailgun.send
        to: person.emails[0].address
        from: 'Planning 24 <no-reply@planning-24.meteor.com>'
        subject: 'Disponible le ' + day.name + ' ?'
        html: 'Bonjour ' + person.profile.firstname + ',<br /><br />' + 'Vous avez été désigné(e) pour "' + task.name + '" le ' + day.name + '.<br /><br />' + '<a href=\'' + Meteor.absoluteUrl('planning/' + planning.slug + '/confirm/' + day._id + '/' + task._id + '/' + person._id) + '\'>Confirmer</a>' + ' / ' + '<a href=\'' + Meteor.absoluteUrl('planning/' + planning.slug + '/decline/' + day._id + '/' + task._id + '/' + person._id) + '\'>Décliner</a><br />'
  sendSMSNotifications: (planningId) ->
    person =
      name: 'Jérémy'
      phone: '+33628055409'
    task =
      name: 'Médiateur, response d\'équipe'
      name: 'Médiateur'
    day = name: 'Samedi 28 Septembre 2015'
    ACCOUNT_SID = 'AC3869695257d0b4105a8286c9bf868c24'
    AUTH_TOKEN = 'f4bd037ce0f2f7e9338b819af6aae578'
    twilio_number = '+15005550006'
    twilio = Twilio(ACCOUNT_SID, AUTH_TOKEN)
    eachDuty planningId, (planning, day, task, person) ->
      twilio.sendSms {
        to: person.phone
        from: twilio_number
        body: 'Bonjour ' + person.name + ',\n' + 'Tu as été désigné pour "' + task.name + '" le ' + day.name + '.\n' + '1 pour confirmer,\n' + '0 pour décliner.'
      }, (err, responseData) ->
  answerNotification: (planningSlug, dayId, taskId, personId, confirmation) ->
    planning = Plannings.findOne(slug: planningSlug)
    duties = planning.duties
    key = dayId + ',' + taskId
    people = duties[key]
    person = people.find(_id: personId)
    set = {}
    person.confirmation = confirmation
    set['duties.' + key] = people
    Plannings.update planning._id, $set: set
    SoundsToPlay.remove {}
    SoundsToPlay.insert filename: if confirmation then '/success.ogg' else '/failure.ogg'
  cycleStatus: (planningId, dayId, taskId, personId) ->
    planning = Plannings.findOne(_id: planningId)
    duties = planning.duties
    key = dayId + ',' + taskId
    people = duties[key]
    person = people.find(_id: personId)
    set = {}
    if person.confirmation == undefined
      person.confirmation = true
    else if person.confirmation == true
      person.confirmation = false
    else if person.confirmation == false
      delete person.confirmation
    set['duties.' + key] = people
    Plannings.update planning._id, $set: set
  togglePresence: (planningId, dayId, personId) ->
    planning = Plannings.findOne(_id: planningId)
    presences = planning.presences
    people = presences[dayId]
    if !people
      people = []
    set = {}
    if people.find(_id: personId)
      people.remove _id: personId
    else
      people.push _id: personId
    set['presences.' + dayId] = people
    Plannings.update planning._id, $set: set
Meteor.startup ->
  if !Plannings.findOne(name: 'Mai 2015')
    days = [
      {_id: guid(), name: 'Vendredi 1er Mai'}
      {_id: guid(), name: 'Samedi 2 Mai'}
      {_id: guid(), name: 'Dimanche 3 Mai'}
      {_id: guid(), name: 'Vendredi 8 Mai'}
      {_id: guid(), name: 'Samedi 9 Mai'}
      {_id: guid(), name: 'Dimanche 10 Mai'}
      {_id: guid(), name: 'Vendredi 15 Mai'}
      {_id: guid(), name: 'Samedi 16 Mai'}
      {_id: guid(), name: 'Dimanche 17 Mai'}
      {_id: guid(), name: 'Vendredi 22 Mai'}
      {_id: guid(), name: 'Samedi 23 Mai'}
      {_id: guid(), name: 'Dimanche 24 Mai'}
      {_id: guid(), name: 'Vendredi 29 Mai'}
      {_id: guid(), name: 'Samedi 30 Mai'}
      {_id: guid(), name: 'Dimanche 31 Mai'}
    ]
    Meteor.call 'createPlanning', 'Mai 2015', days
    Meteor.call 'createPlanning', 'Juin 2015', []

    admin = Accounts.createUser
      username: 'Jérémy Frere'
      email: 'frere.jeremy@gmail.com'
      password: 'canada'
      profile:
        firstname: 'Jérémy'
    Roles.addUsersToRoles(admin, ["admin"]);

    Accounts.createUser
      username: 'Anne Benson'
      email: 'anne.benson@gmail.com'
      password: 'canada'
      profile:
        firstname: 'Anne'

Meteor.publish 'users', ->
  Meteor.users.find()

Meteor.publish 'plannings', ->
  Plannings.find()

Meteor.publish 'sounds_to_play', ->
  SoundsToPlay.find()
