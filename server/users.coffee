Meteor.users.allow
  insert: (-> true)
  update: (-> true)
  remove: (-> true)

generatePassword = ->
  Math.random().toString(10).substr(2, 5)

Meteor.methods
  sendPasswordEmails: ->
    @unblock()
    usersWithoutPassword().each (user) ->
      email = user.emails[0].address
      newPassword = generatePassword()
      Accounts.setPassword(user._id, newPassword, logout: false)
      Meteor.users.update(user._id, $set: passwordEmailSent: true)
      mailgun().send
        to: email
        from: 'Planning 24 <no-reply@planning-24.meteor.com>'
        subject: 'Vos informations de connexion'
        html: 'Bonjour ' + user.profile.firstname + ',<br /><br />' +
              'Ci-dessous voici vos informations de connexion pour Planning 24.' + '.<br /><br />' +
              '<dl>' +
                 "<dt>Nom d'utilisateur</dt><dd>#{email}</dd>" +
                 "<dt>Mot de passe</dt><dd>#{newPassword}</dd>" +
              '</dl>'
