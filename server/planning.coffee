moment.locale('fr')

SoundsToPlay = new (Meteor.Collection)('sounds_to_play')

dutiesByPerson = (planningId, callback) ->
  planning = Plannings.findOne(_id: planningId)
  dutiesByPerson = {}
  Object.keys(planning.duties).each (key) ->
    dayId = key.split(',')[0]
    taskId = key.split(',')[1]
    day = planning.days.find(_id: dayId)
    task = planning.tasks.find(_id: taskId)
    duties = planning.duties[dayId + ',' + taskId]
    duties.each (duty) ->
      dutiesByPerson[duty._id] ||= []
      dutiesByPerson[duty._id].push({day: day, task: task})
  _.each dutiesByPerson, (duties, personId) ->
    person = Meteor.users.findOne(_id: personId)
    callback planning, duties, person

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

markDutyAsSent = (planning, day, task, person) ->
  dutyKey = 'duties.' + day._id + ',' + task._id
  condition = _id: planning._id
  condition[dutyKey] = $elemMatch: _id: person._id
  set = {}
  set["#{dutyKey}.$.emailSent"] = true
  Plannings.update condition, $set: set

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
  createPlanning: (month, year, days) ->
    if !days
      days = []
    tasks = Tasks.find().fetch()
    name = moment().month(parseInt(month)).format('MMMM').capitalize() + ' ' + year
    slug = getSlug(name)
    Plannings.insert
      name: name
      slug: slug
      month: month
      year: year
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
        html: "Bonjour #{person.profile.firstname},<br /><br />" +
              "Pouvez-vous nous indiquer vos disponibilités pour #{month} ?.<br /><br />" +
              "<a href='#{Meteor.absoluteUrl('planning/' + planning.slug)}'>Pour ce faire cliquez-ici</a><br /><br />" +
              'Merci !'
    Plannings.update planningId, $set: { availabilityEmailSent: true }
  sendPresenceEmailNotifications: (planningId) ->
    @unblock()
    dutiesByPerson planningId, (planning, duties, person) ->
      result = mailgun().send
        to: person.emails[0].address
        from: 'Planning 24 <no-reply@planning-24.meteor.com>'
        subject: "Confirmation des dates pour le planning de #{planning.name}"
        html: "Bonjour #{person.profile.firstname},<br /><br />" +
              "Vous avez été désigné(e) pour une ou plusieurs tâches au planning de #{planning.name}<br /><br />" +
              "<a href='#{Meteor.absoluteUrl('planning/' + planning.slug)}'>Cliquez-ici pour confirmer votre présence</a><br /><br />" +
              'Merci !'
      unless result.error
        duties.each (duty) ->
          markDutyAsSent(planning, duty.day, duty.task, person)
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
      {_id: guid(), name: 'Vendredi 1er', date: moment('01-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 2',     date: moment('02-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 3',   date: moment('03-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 8',   date: moment('08-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 9',     date: moment('09-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 10',  date: moment('10-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 15',  date: moment('15-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 16',    date: moment('16-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 17',  date: moment('17-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 22',  date: moment('22-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 23',    date: moment('23-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 24',  date: moment('24-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 29',  date: moment('29-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 30',    date: moment('30-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 31',  date: moment('31-05-2015', 'DD-MM-YYYY').toDate() }
    ]
    Meteor.call 'createPlanning', 5, 2015, days
    Meteor.call 'createPlanning', 6, 2015, []

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
