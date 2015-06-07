eachPersonDutiesForDay = (planning, day, callback) ->
  dutiesByPerson = {}
  _.each planning.duties, (duties, key) ->
    dayId = key.split(',')[0]
    taskId = key.split(',')[1]
    if dayId == day._id
      task = planning.tasks.find(_id: taskId)
      duties.each (duty) ->
        personId = duty._id
        dutiesByPerson[personId] ||= []
        dutiesByPerson[personId].push(task)
  _.each dutiesByPerson, (tasks, personId) ->
    person = Meteor.users.findOne(personId)
    callback person, tasks

Array.prototype.toSentence =  ->
  last = @.pop()
  (last && @.length && [@.join(', '),last] || [last] || @).join(' et ')

@sendTextMessagesForTomorrowsDuties = ->
  tomorrow = moment().add(1, 'day')
  month_number = parseInt(tomorrow.format('M')) - 1
  planningForTomorrowMonth = Plannings.findOne(month: month_number.toString(), year: tomorrow.format('YYYY'))
  if dayForTomorrow = planningForTomorrowMonth.days.find(date: tomorrow.toDate().beginningOfDay())
    eachPersonDutiesForDay planningForTomorrowMonth, dayForTomorrow, (person, tasks) ->
      if phone = person.profile.phone
        internationalPhone = '33' + phone.substr(1)
        taskNames = tasks.map((task) -> "\"#{task.name}\"").toSentence()
        Nexmo.initialize('ff867a54', '8699ec31', 'https')
        Nexmo.sendTextMessage('Planning 24', internationalPhone, "Rappel : Vous avez été désigné demain #{dayForTomorrow.name} pour #{taskNames}")

Meteor.methods
  testSendMessages: ->
    sendTextMessagesForTomorrowsDuties()
