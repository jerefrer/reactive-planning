Template.UserPresence.helpers
  unavailableTheWholeMonth: ->
    unavailableTheWholeMonth(@planning, Meteor.user())
  availabilitiesActive: ->
    availabilitiesActive()
  availabilitiesDisabledClass: ->
    'availabilities-disabled' if !availabilitiesActive() || unavailableTheWholeMonth(@planning, Meteor.user())

Template.UserPresence.events
  'click button.notAvailable': (event) ->
    addOverlay()
    successPopup("Nous avons bien noté que vous n'êtes pas disponible ce mois. Vous ne recevrez plus les e-mails le concernant.", 5000)
    Meteor.call 'markAsUnavailableForTheMonth', @planning._id, Meteor.userId()
  'click button.becomeAvailable': (event) ->
    removeOverlay()
    successPopup("Vous recevrez de nouveau les e-mails concernant ce mois. Merci de cocher les jours où vous êtes disponible.", 5000)
    Meteor.call 'markAsAvailableForTheMonth', @planning._id, Meteor.userId()
