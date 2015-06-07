eachDuty = (planning, callback) ->
  Object.keys(planning.duties).each (key) ->
    dayId = key.split(',')[0]
    taskId = key.split(',')[1]
    day = planning.days.find(_id: dayId)
    task = planning.tasks.find(_id: taskId)
    duties = planning.duties[dayId + ',' + taskId]
    duties.each (duty) ->
      person = Meteor.users.findOne(_id: duty._id)
      callback day, task, person

SyncedCron.add
  name: 'Send text messages the day before a duty'
  schedule: (parser) ->
    parser.text('at 9:50 am')
  job: ->
    tomorrow = moment().add(1, 'day')
    month_number = parseInt(tomorrow.format('M')) - 1
    planningForTomorrowMonth = Plannings.findOne(month: month_number.toString(), year: tomorrow.format('YYYY'))
    if dayForTomorrow = planningForTomorrowMonth.days.find(date: tomorrow.toDate().beginningOfDay())
      eachDuty planningForTomorrowMonth, (day, task, person) ->
        if day._id == dayForTomorrow._id
          if phone = person.profile.phone
            internationalPhone = '33' + phone.substr(1)
            Nexmo.initialize('ff867a54', '8699ec31', 'https')
            Nexmo.sendTextMessage('Planning 24', internationalPhone, "Rappel : Vous avez été désigné pour \"#{task.name}\" demain #{day.name} !")

SyncedCron.start()
