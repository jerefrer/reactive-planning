userIsSelected = ->
  !!Session.get('selectedUserId')

areInactive = ->
  $or: [active: false, active: null, active: $exists: false]

numberOfUsersToActivate = ->
  Meteor.users.find(areInactive()).count()

anyUserToActivate = ->
  numberOfUsersToActivate() > 0

showInactiveUsers = ->
  Session.get('showInactiveUsers')

resetForm = ->
  Session.set 'selectedUserId', null
  setTimeout (->
    AutoForm.resetForm 'userForm'
  ), 100

goBackToAllUsersIfNoMoreUsersToActivate = ->
  Session.set('showInactiveUsers', false) unless anyUserToActivate()

Template.Users.helpers
  passwordEmailsToSend: ->
    !!usersWithoutPassword().length
  userIsSelected: ->
    userIsSelected()
  anyUserToActivate: ->
    anyUserToActivate()
  numberOfUsersToActivate: ->
    numberOfUsersToActivate()
  pluralizedNumberOfUsersToActivate: ->
    pluralize('inscription', numberOfUsersToActivate(), true)
  showInactiveUsers: ->
    showInactiveUsers()
  selector: ->
    if anyUserToActivate() && showInactiveUsers()
      areInactive()
    else
      active: true

Template.Users.events
  'click button.addUser': (event) ->
    resetForm()
  'click button.toggleShowInactiveUsers': (event) ->
    Session.set 'showInactiveUsers', !Session.get('showInactiveUsers')
    resetForm()
  'click tbody > tr': (event) ->
    dataTable = $(event.target).closest('table').DataTable()
    user = dataTable.row(event.currentTarget).data()
    Session.set 'selectedUserId', user._id
    setTimeout ->
      React.render(
        <ChangePasswordModalTrigger user={user} />,
        document.getElementById('change-password-modal-trigger')
      )
    , 200

Template.UserForm.helpers
  formType: ->
    if userIsSelected() then 'update' else 'insert'
  selectedUser: ->
    Meteor.users.findOne Session.get('selectedUserId')
  userIsSelected: ->
    userIsSelected()
  showInactiveUsers: ->
    showInactiveUsers()
  beforeRemove: ->
    (collection, id) ->
      user = collection.findOne(id);
      if confirm("Voulez vous vraiment supprimer #{user.username} ?")
        @remove()
        goBackToAllUsersIfNoMoreUsersToActivate()
        resetForm()

Template.UserForm.events
  'click button.confirmSelectedUser': (event) ->
    if confirm('Êtes-vous sûr de vouloir confirmer cette inscription ?')
      $(event.target).html('<i class="fa fa-spinner fa-spin" />').prop('disabled', true)
      $(event.target).siblings('button').prop('disabled', true)
      Meteor.call 'confirmUserAndSendWelcomeEmail', Session.get('selectedUserId'), (error, data) =>
        goBackToAllUsersIfNoMoreUsersToActivate()
        resetForm()

AutoForm.hooks
  userForm:
    after:
      insert: (error, userId) ->
        Meteor.call 'confirmUser', userId
