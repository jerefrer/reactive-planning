userPresentForDay = (planning, day) ->
  _.find planning.presences, (dutiesForDay, key) ->
    key.split(',')[0] == day._id and dutiesForDay.find (duty) -> duty._id == Meteor.userId()

Template.UserPresence.helpers
  calendarOptions: ->
    id: 'user-presence-calendar'
    height: 600
    lang: 'fr'
    defaultDate: Plannings.findOne(slug: @slug).days.first().date
    columnFormat: 'dddd'
    header: false
    events: (start, end, timezone, callback) =>
      callback Plannings.findOne(slug: @slug).days.map (day) ->
        id:    day._id,
        title: day.name,
        start: day.date,
        end:   day.date,
        day:   day
    eventRender: (event, element) =>
      if userPresentForDay(Plannings.findOne(slug: @slug), event.day)
        checkboxClass = "fa fa-check-square-o text-success"
      else
        checkboxClass = "fa fa-square-o text-muted"
      element.find('.fc-content').html "<i class='#{checkboxClass}' />"
      element
    eventClick: (event, jsEvent, view) =>
      console.log(event.day._id)
      Meteor.call 'togglePresence', @planning._id, event.day._id, Meteor.userId(), ->
        $('#user-presence-calendar').fullCalendar('refetchEvents')