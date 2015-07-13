userPresentForDay = (planning, day) ->
  _.find planning.presences, (dutiesForDay, key) ->
    key.split(',')[0] == day._id and dutiesForDay.find (duty) -> duty._id == Meteor.userId()

Template.UserPresence.helpers
  unavailableTheWholeMonth: ->
    unavailableTheWholeMonth(@planning, Meteor.user())
  unavailableTheWholeMonthClass: ->
    'unavailableTheWholeMonth' if unavailableTheWholeMonth(@planning, Meteor.user())
  calendarOptions: ->
    id: 'user-presence-calendar'
    height: 600
    lang: 'fr'
    defaultDate: @planning.days.first().date
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
      successPopup()
      Meteor.call 'togglePresence', @planning._id, event.day._id, Meteor.userId(), ->
        $('#user-presence-calendar').fullCalendar('refetchEvents')

removeOverlay = ->
  $('#user-presence-calendar').find('.inactive-overlay').remove()
addOverlay = ->
  removeOverlay()
  $('#user-presence-calendar').append('<div class="inactive-overlay"></div>')

Template.UserPresence.events
  'click button.notAvailable': (event) ->
    addOverlay()
    successPopup("Nous avons bien noté que vous n'êtes pas disponible ce mois. Vous ne recevrez plus les e-mails le concernant.", 5000)
    Meteor.call 'markAsUnavailableForTheMonth', @planning._id, Meteor.userId()
  'click button.becomeAvailable': (event) ->
    removeOverlay()
    successPopup("Vous recevrez de nouveau les e-mails concernant ce mois. Merci de cocher les jours où vous êtes disponible.", 5000)
    Meteor.call 'markAsAvailableForTheMonth', @planning._id, Meteor.userId()
