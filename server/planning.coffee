moment.locale('fr')

SoundsToPlay = new (Meteor.Collection)('sounds_to_play')

foreachDutiesByPerson = (planningId, callback, conditionFunction) ->
  planning = Plannings.findOne(_id: planningId)
  dutiesByPerson = {}
  conditionFunction ||= (-> true)
  Object.keys(planning.duties).each (key) ->
    dayId = key.split(',')[0]
    taskId = key.split(',')[1]
    day = planning.days.find(_id: dayId)
    task = planning.tasks.find(_id: taskId)
    duties = planning.duties[dayId + ',' + taskId]
    duties.each (duty) ->
      dutiesByPerson[duty._id] ||= []
      dutiesByPerson[duty._id].push({day: day, task: task}) if conditionFunction(duty)
  _.each dutiesByPerson, (duties, personId) ->
    person = Meteor.users.findOne(_id: personId)
    callback planning, duties, person if duties.length > 0

foreachDutiesNotSentByPerson =  (planningId, callback) ->
  foreachDutiesByPerson planningId, callback, ((duty) -> not duty.emailSent)

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

markDutyAsSent = (planning, day, task, person) ->
  dutyKey = 'duties.' + day._id + ',' + task._id
  condition = _id: planning._id
  condition[dutyKey] = $elemMatch: _id: person._id
  set = {}
  set["#{dutyKey}.$.emailSent"] = true
  Plannings.update condition, $set: set

sendAvailabilityEmail = (planning, users, subject) ->
  users.each (person) ->
    email = person.emails[0].address
    unless emailIsFake(email)
      options = _.extend {},
        heading: "Bonjour #{person.profile.firstname}"
        headingSmall: "Pouvez-vous nous indiquer vos disponibilités pour #{planning.name} ?"
        message: "Cliquez sur le bouton bleu ci-dessous pour accéder à l'application.<br />"+
                 "<hr />" +
                 '<h4 style="text-align: center">Pour remplir vos disponibilités, il suffit de cocher les postes qui vous intéressent.</h4><br />' +
                 '<div style="text-align: center">' +
                   "<img src='#{Meteor.absoluteUrl('click_availability.gif')}' />" +
                 '</div>' +
                 '<h4 style="text-align: center">Nous avons aussi ajouté la possibilité de laisser un message directement sur le planning.</h4><br />' +
                 '<div style="text-align: center">' +
                   "<img src='#{Meteor.absoluteUrl('add_message_on_availability.gif')}' />" +
                 '</div>'
        buttonUrl: loginUrlTo("planning/#{planning.slug}/presences")
        buttonText: "Indiquer mes disponibilités"
      html = PrettyEmail.render 'call-to-action', options
      mailgun().send
        to: email
        from: 'Planning Maison 24 <planning@lamaison24.fr>'
        subject: subject
        html: html

weeklyEvents = [
  { "weekDay": 0, "name": "13:00 - 17:00", "detail": "Distribution", "required": false, "group_id": 1 },
  { "weekDay": 0, "name": "13:00 - 17:00", "detail": "Accueil",      "required": false, "group_id": 1 },

  { "weekDay": 1, "name": "17:15 - 20:30", "detail": "Distribution", "required": false, "group_id": 1 },
  { "weekDay": 1, "name": "17:15 - 20:30", "detail": "Voiture ?",    "required": false, "group_id": 1 },

  { "weekDay": 3, "name": "17:15 - 20:30", "detail": "Distribution", "required": false, "group_id": 1 },
  { "weekDay": 3, "name": "17:15 - 20:30", "detail": "Voiture ?",    "required": false, "group_id": 1 },

  { "weekDay": 5, "name": "09:00 - 12:00", "detail": "Distribution", "required": false, "group_id": 1 },
  { "weekDay": 5, "name": "09:00 - 12:00", "detail": "Déchargement", "required": false, "group_id": 1 },
  { "weekDay": 5, "name": "09:00 - 12:00", "detail": "Accueil",      "required": false, "group_id": 1 }
  { "weekDay": 5, "name": "17:15 - 20:30", "detail": "Distribution", "required": false, "group_id": 2 },
  { "weekDay": 5, "name": "17:15 - 20:30", "detail": "Voiture ?",    "required": false, "group_id": 2 },
]

buildEventFromWeeklyEvents = (month, year) ->
  daysInMonth = moment({day: 1, month: month, year: year}).daysInMonth()
  _.flatten _.map [1..daysInMonth], (day) =>
    date = new Date(year, month, day)
    weeklyEventsForDay = weeklyEvents.findAll weekDay: moment(date).weekday()
    weeklyEventsForDay.map (event) ->
      Object.extended(event).clone().merge(_id: Random.id(), date: date, availablePeople: [])

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
      unavailableTheWholeMonth: []
      daysFilledIn: false
      availabilityEmailSent: false
      events: buildEventFromWeeklyEvents(month, year)
      messagesForAvailabilityDays: {}
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
  updateDay: (planningId, dayId, name, date) ->
    Plannings.update {
      _id: planningId
      days: $elemMatch: _id: dayId
    }, $set: 'days.$.name': name, 'days.$.date': moment(date, 'DD-MM-YYYY').toDate()
  updateTask: (planningId, taskId, name, description) ->
    Plannings.update {
      _id: planningId
      tasks: $elemMatch: _id: taskId
    }, $set: 'tasks.$.name': name, 'tasks.$.description': description
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
  sendAvailabilityEmailNotifications: (planningId) ->
    @unblock()
    planning = Plannings.findOne(_id: planningId)
    sendAvailabilityEmail(planning, Meteor.users.find().fetch(), "Vos disponilités pour #{planning.name}")
    Plannings.update planningId, $set: { availabilityEmailSent: true }
  sendAvailabilityReminder: (planningId) ->
    @unblock()
    planning = Plannings.findOne(_id: planningId)
    usersToSendReminderTo = Meteor.users.find().fetch().findAll (person) ->
      planning.peopleWhoAnswered.indexOf(person._id) < 0 and not unavailableTheWholeMonth(planning, person)
    sendAvailabilityEmail(planning, usersToSendReminderTo, "Vous n'avez pas encore donné vos disponilités pour #{planning.name}")
  sendPresenceEmailNotifications: (planningId) ->
    @unblock()
    foreachDutiesNotSentByPerson planningId, (planning, duties, person) ->
      email = person.emails[0].address
      unless emailIsFake(email)
        options = _.extend {},
          heading: "Bonjour #{person.profile.firstname}"
          headingSmall: "Vous avez été désigné(e) pour une ou plusieurs tâches au planning de #{planning.name}"
          message: "Merci de nous confirmer si vous pourrez être présent ou non les jours proposés.<br />"+
                   "Il vous suffit de cliquer au bon endroit : <img src='#{Meteor.absoluteUrl('confirm_presence_demo.png')}' style='vertical-align: middle'/>"
          buttonUrl: loginUrlTo("planning/#{planning.slug}")
          buttonText: "Confirmer mes rendez-vous"
        html = PrettyEmail.render 'call-to-action', options
        result = mailgun().send
          to: person.emails[0].address
          from: 'Planning Maison 24 <planning@lamaison24.fr>'
          subject: "Confirmation des dates pour le planning de #{planning.name}"
          html: html
        unless result.error
          duties.each (duty) ->
            markDutyAsSent(planning, duty.day, duty.task, person)
  togglePlanningComplete: (planningId) ->
    planning = Plannings.findOne(_id: planningId)
    Plannings.update planningId, $set: { complete: !planning.complete }
  sendPlanningCompleteEmail: (planningId) ->
    @unblock()
    planning = Plannings.findOne(_id: planningId)
    month = planning.name
    excelExportPath = './tmp/' + planning.slug + '.xlsx'
    excelExportPlanning(planning, excelExportPath)
    foreachDutiesByPerson planningId, (planning, duties, person) ->
      email = person.emails[0].address
      unless emailIsFake(email) or unavailableTheWholeMonth(planning, person)
        options = _.extend {},
          heading: "Bonjour #{person.profile.firstname}"
          headingSmall: "Le planning de #{month} est disponible"
          message: "Et vous avez #{duties.length} rendez-vous de prévu#{duties.length > 1 && 's' || ''}.<br /><br />" +
                   "Vous trouverez également en pièce jointe le planning au format Excel. Il n'est pas encore aussi beau que l'ancien, mais on y travaille !"
          buttonUrl: loginUrlTo("planning/#{planning.slug}")
          buttonText: "Voir le planning"
        html = PrettyEmail.render 'call-to-action', options
        mailgun().send
          to: email
          from: 'Planning Maison 24 <planning@lamaison24.fr>'
          subject: "Le planning de #{month} est disponible"
          html: html
          attachment: excelExportPath
    Plannings.update planningId, $set: { excelFileSent: true }
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
  togglePresence: (planningId, eventId, personId, fromAdmin) ->
    planning = Plannings.findOne(_id: planningId)
    events = planning.events
    event = events.find(_id: eventId)
    availablePeople = event.availablePeople
    peopleWhoAnswered = planning.peopleWhoAnswered || []
    set = {}
    if availablePeople.indexOf(personId) >= 0
      availablePeople.remove(personId)
      if event.required
        optionalEventsForSameEventGroup = events.findAll(date: event.date, group_id: event.group_id, required: false)
        optionalEventsForSameEventGroup.each (optionalEvent) ->
          optionalEvent.availablePeople.remove(personId)
    else
      availablePeople.push personId
      unless fromAdmin || (peopleWhoAnswered.indexOf(personId) >= 0)
        peopleWhoAnswered.push(personId)
        set.peopleWhoAnswered = peopleWhoAnswered
    set.events = events
    Plannings.update { _id: planningId }, $set: set
  setMessageForAvailabilityDay: (planningId, date, personId, message) ->
    planning = Plannings.findOne(_id: planningId)
    if messagesForDay = planning.messagesForAvailabilityDays[date]
      if messagesForDay.find(userId: personId)
        condition = _id: planningId
        condition["messagesForAvailabilityDays.#{date}"] = $elemMatch: userId: personId
        set = {}
        set["messagesForAvailabilityDays.#{date}.$"] = userId: personId, message: message
        Plannings.update condition, $set: set
      else
        push = {}
        push["messagesForAvailabilityDays.#{date}"] = { userId: personId, message: message }
        Plannings.update { _id: planningId }, $push: push
    else
      set = {}
      set["messagesForAvailabilityDays.#{date}"] = [{ userId: personId, message: message}]
      Plannings.update { _id: planningId }, $set: set
    unless planning.peopleWhoAnswered.indexOf(personId) >= 0
      Plannings.update { _id: planningId }, $push: peopleWhoAnswered: personId
  removeMessageForAvailabilityDay: (planningId, date, personId) ->
    pull = {}
    pull["messagesForAvailabilityDays.#{date}"] = { userId: personId }
    Plannings.update { _id: planningId }, $pull: pull
  markAsUnavailableForTheMonth: (planningId, personId) ->
    planning = Plannings.findOne(_id: planningId)
    peopleWhoAnswered = planning.peopleWhoAnswered || []
    set = {}
    unless peopleWhoAnswered.indexOf(personId) >= 0
      peopleWhoAnswered.push(personId)
      set.peopleWhoAnswered = peopleWhoAnswered
    set.unavailableTheWholeMonth = planning.unavailableTheWholeMonth || []
    set.unavailableTheWholeMonth.push(personId)
    Plannings.update planning._id, $set: set
  markAsAvailableForTheMonth: (planningId, personId) ->
    planning = Plannings.findOne(_id: planningId)
    unavailableTheWholeMonth = planning.unavailableTheWholeMonth
    unavailableTheWholeMonth.remove(personId)
    Plannings.update planning._id, $set: unavailableTheWholeMonth: unavailableTheWholeMonth

Meteor.publish 'users', ->
  Meteor.users.find()

Meteor.publish 'tasks', ->
  Tasks.find()

Meteor.publish 'plannings', ->
  Plannings.find()

Meteor.publish 'sounds_to_play', ->
  SoundsToPlay.find()
