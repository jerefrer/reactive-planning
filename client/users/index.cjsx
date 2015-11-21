Template.Users.helpers
  passwordEmailsToSend: ->
    !!usersWithoutPassword().length

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
    setTimeout ->
      React.render(
        <ChangePasswordModalTrigger user={user} />,
        document.getElementById('change-password-modal-trigger')
      )
    , 200

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
