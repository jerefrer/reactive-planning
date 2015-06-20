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
      unless emailIsFake(email)
        options = _.extend {},
          heading: "Bonjour #{user.profile.firstname}"
          headingSmall: '<br />Et bienvenue dans Planning 24,<br />le nouvel outil de gestion des plannings de La Maison 24'
          message: 'Voici vos identifiants personnels pour vous y connecter'+
                   '<table style="margin: 0 auto">' +
                      '<tr>' +
                        '<td style="padding: 0">Nom d\'utilisateur</td>' +
                        '<td style="padding: 0" width=20></td>' +
                        "<td style='padding: 0'><strong>#{user.username}</strong></td>" +
                      '</tr>' +
                      '<tr>' +
                        '<td style="padding: 0">Mot de passe</td>' +
                        '<td style="padding: 0" width=20></td>' +
                        "<td style='padding: 0'><strong>#{newPassword}</strong></td>" +
                      '</tr>' +
                   '</table>' +
                   '<br />' +
                   '<div style="text-align: center">' +
                     "Vous pourrez vous connecter en cliquant sur le bouton \"Connexion\" " +
                     "puis en remplissant votre nom d'utilisateur et votre mot de passe, comme dans l'exemple ci-dessous.<br />" +
                     "<strong>Il est important de respecter les majuscules et minuscules.</strong></br /><br />" +
                     "<img src='#{Meteor.absoluteUrl('sign_in_demo.png')}' /><br />" +
                     "Si vous préférez choisir vous-même votre mot de passe, une fois connecté vous pourrez le modifier en " +
                     "cliquant sur votre nom en haut à droite puis sur \"Changer le mot de passe\", comme dans l'exemple ci-dessous.<br /><br />" +
                     "<img src='#{Meteor.absoluteUrl('update_password_demo.png')}' />" +
                   '</div>'
          buttonUrl: Meteor.absoluteUrl('/')
          buttonText: "Me connecter à Planning 24"
        html = PrettyEmail.render 'call-to-action', options
        mailgun().send
          to: email
          from: 'Planning 24 <no-reply@planning-24.meteor.com>'
          subject: 'Vos informations de connexion'
          html: html
