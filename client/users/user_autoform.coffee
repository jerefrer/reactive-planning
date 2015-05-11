Schemas = {}
Template.registerHelper 'Schemas', Schemas
Schemas.UserProfile = new SimpleSchema
  firstname:
    type: String
    label: 'Prénom'
  phone:
    type: String
    label: 'Téléphone'
    optional: true
Schemas.User = new SimpleSchema
  username:
    type: String
    label: 'Nom complet'
  emails:
      type: [Object]
  "emails.$.address":
      type: String
      regEx: SimpleSchema.RegEx.Email
      autoform:
        label: false
  profile:
    type: Schemas.UserProfile
  passwordEmailSent:
    type: Boolean
    label: 'A reçu un e-mail avec son mot de passe ? Mettre à non pour regénérer un mot de passe et le renvoyer par email au prochain clic sur "Envoyer les mots de passe"'
    optional: true

Collections = {}
Template.registerHelper 'Collections', Collections
@Users = Collections.Users = Meteor.users
@Users.attachSchema Schemas.User

resetForm = ->
  Session.set 'selectedUserId', null
  setTimeout (->
    AutoForm.resetForm 'userForm'
  ), 100

Template.Users.events
  'click button.addUser': (event) ->
    resetForm()
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
  beforeRemove: ->
    (collection, id) ->
      user = collection.findOne(id);
      if confirm("Voulez vous vraiment supprimer #{user.username} ?")
        @remove()
        resetForm()
