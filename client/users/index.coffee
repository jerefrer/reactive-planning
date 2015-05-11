Template.Users.helpers
  passwordEmailsToSend: ->
    !!usersWithoutPassword().length
