Template.EditProfile.helpers
  currentUser: ->
    Meteor.user()

AutoForm.hooks
  editProfileForm:
    after:
      update: ->
        successPopup("Modifications enregistrées.")
