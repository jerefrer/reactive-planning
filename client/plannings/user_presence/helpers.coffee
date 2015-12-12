@removeOverlay = ->
  $('#user-presence-calendar').find('.inactive-overlay').remove()
@addOverlay = ->
  removeOverlay()
  $('#user-presence-calendar').append('<div class="inactive-overlay"></div>')

@availabilitiesActive = ->
  dayNumber = moment().date()
  dayNumber >= 10 && dayNumber <= 20
