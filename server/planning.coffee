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
        message: "Il vous suffit de cocher les jours où vous êtes disponibes.<br />" +
                 '<div style="text-align: center">' +
                   "<img src='#{Meteor.absoluteUrl('availabilities_demo.png')}' />" +
                 '</div>' +
                 '<br />' +
                 "<strong>Si vous n'êtes pas disponible du tout ou n'êtes pas encore sûr de vos disponibilités, merci de nous l'indiquer en cliquant sur le bouton comme indiqué ci-dessous.</strong>" +
                 '<br />' +
                 'Vous pourrez toujours revenir modifier votre choix plus tard.' +
                 '<div style="text-align: center">' +
                   "<img src='#{Meteor.absoluteUrl('unavailable_demo.png')}' />" +
                 '</div>'
        buttonUrl: Meteor.absoluteUrl("planning/#{planning.slug}/presences")
        buttonText: "Indiquer mes disponibilités"
      html = PrettyEmail.render 'call-to-action', options
      mailgun().send
        to: email
        from: 'Planning 24 <no-reply@planning-24.meteor.com>'
        subject: subject
        html: html

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
          buttonUrl: Meteor.absoluteUrl("planning/#{planning.slug}")
          buttonText: "Confirmer mes rendez-vous"
        html = PrettyEmail.render 'call-to-action', options
        result = mailgun().send
          to: person.emails[0].address
          from: 'Planning 24 <no-reply@planning-24.meteor.com>'
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
          buttonUrl: Meteor.absoluteUrl("planning/#{planning.slug}")
          buttonText: "Voir le planning"
        html = PrettyEmail.render 'call-to-action', options
        mailgun().send
          to: email
          from: 'Planning 24 <no-reply@planning-24.meteor.com>'
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
