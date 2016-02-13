Template.Layout.helpers
  containerType: ->
    fluid = Session.get('fluid') || false
    type = "container"
    type += "-fluid" if fluid
    type

Template.Nav.events
  "click .toggleFluid": ->
    fluid = Session.get('fluid') || false
    Session.set('fluid', !fluid)
Template.Nav.helpers
  isFluid: ->
    Session.get('fluid')

Template._loginButtonsLoggedInDropdownActions.onRendered ->
  if Meteor.user() && $('#edit-profile-button').length == 0
    $('#login-buttons-open-change-password').before(
      '<div class="login-button" id="edit-profile-button">' +
        '<a href="/modifier-mon-profil" class="btn btn-default btn-block">Modifier mon profil</a>' +
      '</div>'
    )

i18n.map 'fr',
  loginButtonsLoggedOutPasswordService:
    create: 'Créer mon compte'
  loginButtonsLoggedInDropdownActions:
    password: 'Changer mon mot de passe'
