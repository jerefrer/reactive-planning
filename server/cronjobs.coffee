SyncedCron.add
  name: 'Send text messages the day before a duty'
  schedule: (parser) ->
    parser.text('at 12:00 am')
  job: ->
    sendTextMessagesForTomorrowsDuties()

SyncedCron.start()
