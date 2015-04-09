Schemas = {}
Template.registerHelper 'Schemas', Schemas
Schemas.UserProfile = new SimpleSchema(
  firstname:
    type: String
    label: 'Prénom'
  phone:
    type: String
    label: 'Téléphone')
Schemas.User = new SimpleSchema(
  username:
    type: String
    label: 'Nom complet'
  email:
    type: String
    label: 'E-mail'
    regEx: SimpleSchema.RegEx.Email
  profile: type: Schemas.UserProfile)

Collections = {}
Template.registerHelper 'Collections', Collections
@Users = Collections.Users = Meteor.users
@Users.attachSchema Schemas.User

Template.Users.events
  'click button.addUser': (event) ->
    Session.set 'selectedUserId', null
    setTimeout (->
      AutoForm.resetForm 'userForm'
    ), 100
  'click tbody > tr': (event) ->
    dataTable = $(event.target).closest('table').DataTable()
    user = dataTable.row(event.currentTarget).data()
    Session.set 'selectedUserId', user._id

userIsSelected = ->
  !!Session.get('selectedUserId')

Template.Users.helpers
  userIsSelected: ->
    userIsSelected()

Template.UserForm.helpers
  formType: ->
    if userIsSelected() then 'update' else 'insert'
  selectedUser: ->
    Meteor.users.findOne Session.get('selectedUserId')
  userIsSelected: ->
    userIsSelected()
