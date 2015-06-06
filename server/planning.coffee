Plannings = new (Meteor.Collection)('plannings')
Tasks = new (Meteor.Collection)('tasks')
SoundsToPlay = new (Meteor.Collection)('sounds_to_play')

eachDuty = (planningId, callback) ->
  planning = Plannings.findOne(_id: planningId)
  Object.keys(planning.duties).each (key) ->
    dayId = key.split(',')[0]
    taskId = key.split(',')[1]
    day = planning.days.find(_id: dayId)
    task = planning.tasks.find(_id: taskId)
    duties = planning.duties[dayId + ',' + taskId]
    duties.each (duty) ->
      person = Meteor.users.findOne(_id: duty._id)
      callback planning, day, task, person

anyEmailToSend = (duties) ->
  Object.keys(duties).any (dayTaskKey) ->
    duties[dayTaskKey].any (duty) ->
      duty.emailSent == undefined

markAllDutiesAsSent = (planningId) ->
  planning = Plannings.findOne(_id: planningId)
  marked_duties = planning.duties
  Object.keys(marked_duties).each (dayTaskKey) ->
    marked_duties[dayTaskKey].each (duty) ->
      duty.emailSent = true
  Plannings.update planning._id, $set: { duties: marked_duties, emailsSent: true }

initializeTasks = ->
  ['Banque alimentaire',
   'Médiateur, responsable d\'équipe' ,
   'Chercher pain'
   'Ramasse Carrefour Market',
   'Préparer soupe',
   'Amener soupe',
   'Camion',
   'Chargement',
   'Accueil & Distribution',
   'Fourniture comptoir',
   'Servir café & soupe',
   'Déchargement & Vaisselle local',
   'Suppléants'].each (name) ->
    Tasks.insert name: name

Meteor.methods
  createPlanning: (name, days) ->
    if !days
      days = []
    tasks = Tasks.find().fetch()
    slug = getSlug(name)
    Plannings.insert
      name: name
      slug: slug
      days: days
      tasks: tasks
      presences: {}
      duties: {}
      peopleWhoAnswered: []
      daysFilledIn: false
      availabilityEmailSent: false
      emailsToSend: false
    slug
  removePlanning: (planningId) ->
    Plannings.remove planningId
  addDay: (planningId, dayName, dayDate) ->
    planning = Plannings.findOne(_id: planningId)
    days = planning.days
    days.push
      _id: guid()
      name: dayName
      date: moment(dayDate, 'DD-MM-YYYY').toDate()
    Plannings.update planning._id, $set: days: days
  updateDay: (planningId, day, newName, newDate) ->
    Plannings.update {
      _id: planningId
      days: $elemMatch: _id: day._id
    }, $set: 'days.$.name': newName, 'days.$.date': moment(newDate, 'DD-MM-YYYY').toDate()
  addPerson: (planningId, day, task, person) ->
    planning = Plannings.findOne(_id: planningId)
    duties = planning.duties
    people = duties[day._id + ',' + task._id] || []
    if !people.find(_id: person._id)
      people.push _id: person._id
      set = { emailsToSend: true, emailsSent: false }
      set['duties.' + day._id + ',' + task._id] = people
      Plannings.update planning._id, $set: set
  removePerson: (planningId, day, task, person) ->
    planning = Plannings.findOne(_id: planningId)
    duties = planning.duties
    people = duties[day._id + ',' + task._id]
    people.remove _id: person._id
    emailsToSend = anyEmailToSend(duties)
    set = { emailsToSend: emailsToSend }
    set['emailsSent'] = false if emailsToSend
    set['duties.' + day._id + ',' + task._id] = people
    Plannings.update planning._id, $set: set
  clearDuties: (planningId) ->
    Plannings.update planningId, $set: { duties: {}, emailsToSend: false }
  sendAvailabilityEmailNotifications: (planningId) ->
    @unblock()
    planning = Plannings.findOne(_id: planningId)
    month = planning.name
    Meteor.users.find().fetch().each (person) ->
      mailgun().send
        to: person.emails[0].address
        from: 'Planning 24 <no-reply@planning-24.meteor.com>'
        subject: "Vos disponilités pour #{month}"
        html: 'Bonjour ' + person.profile.firstname + ',<br /><br />' +
              "Pouvez-vous nous indiquer vos disponibilités pour #{month} ?.<br /><br />" +
              '<a href=\'' + Meteor.absoluteUrl('planning/' + planning.slug) +'\'>Pour ce faire cliquez-ici</a><br />< br />' +
              'Merci !'
    Plannings.update planningId, $set: { availabilityEmailSent: true }
  sendPresenceEmailNotifications: (planningId) ->
    @unblock()
    eachDuty planningId, (planning, day, task, person) ->
      mailgun().send
        to: person.emails[0].address
        from: 'Planning 24 <no-reply@planning-24.meteor.com>'
        subject: 'Disponible le ' + day.name + ' ?'
        html: 'Bonjour ' + person.profile.firstname + ',<br /><br />' +
              'Vous avez été désigné(e) pour "' + task.name + '" le ' + day.name + '.<br /><br />' +
              '<a href=\'' + Meteor.absoluteUrl('planning/' + planning.slug + '/confirm/' + day._id + '/' + task._id + '/' + person._id) + '\'>Confirmer</a>' +
              ' / ' +
              '<a href=\'' + Meteor.absoluteUrl('planning/' + planning.slug + '/decline/' + day._id + '/' + task._id + '/' + person._id) + '\'>Décliner</a><br />'
    markAllDutiesAsSent(planningId)
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
      person.emailSent = true
    else if person.confirmation == true
      person.confirmation = false
      person.emailSent = true
    else if person.confirmation == false
      delete person.confirmation
      person.emailSent = false
    set['duties.' + key] = people
    Plannings.update planning._id, $set: set
  togglePresence: (planningId, dayId, personId, fromAdmin) ->
    planning = Plannings.findOne(_id: planningId)
    presences = planning.presences
    people = presences[dayId] || []
    peopleWhoAnswered = planning.peopleWhoAnswered || []
    set = {}
    if people.find(_id: personId)
      people.remove _id: personId
    else
      people.push _id: personId
      unless fromAdmin || (peopleWhoAnswered.indexOf(personId) >= 0)
        peopleWhoAnswered.push(personId)
        set.peopleWhoAnswered = peopleWhoAnswered
    set['presences.' + dayId] = people
    Plannings.update planning._id, $set: set

Meteor.startup ->
  if Tasks.find().fetch().length == 0
    initializeTasks()
  if !Plannings.findOne(name: 'Mai 2015')
    days = [
      {_id: guid(), name: 'Vendredi 1er Mai', date: moment('01-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 2 Mai',     date: moment('02-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 3 Mai',   date: moment('03-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 8 Mai',   date: moment('08-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 9 Mai',     date: moment('09-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 10 Mai',  date: moment('10-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 15 Mai',  date: moment('15-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 16 Mai',    date: moment('16-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 17 Mai',  date: moment('17-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 22 Mai',  date: moment('22-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 23 Mai',    date: moment('23-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 24 Mai',  date: moment('24-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 29 Mai',  date: moment('29-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 30 Mai',    date: moment('30-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 31 Mai',  date: moment('31-05-2015', 'DD-MM-YYYY').toDate() }
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
    Meteor.users.update({username: 'Jérémy Frere'}, $set: {passwordEmailSent: true})

    Accounts.createUser
      username: 'Anne Benson'
      email: 'tatamonique@gmail.com'
      password: 'canada'
      profile:
        firstname: 'Anne'
    Meteor.users.update({username: 'Anne Benson'}, $set: {passwordEmailSent: true})

Meteor.publish 'users', ->
  Meteor.users.find()

Meteor.publish 'tasks', ->
  Tasks.find()

Meteor.publish 'plannings', ->
  Plannings.find()

Meteor.publish 'sounds_to_play', ->
  SoundsToPlay.find()
