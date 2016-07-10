Meteor.users.allow
  insert: (-> true)
  update: (-> true)
  remove: (-> true)

generatePassword = ->
  Math.random().toString(10).substr(2, 5)

confirmUser = (userId) ->
  Meteor.users.update userId, $set: { active: true, passwordEmailSent: true }

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
          headingSmall: "<br />Et bienvenue dans l'outil de gestion des plannings de La Maison 24"
          message: 'Voici vos identifiants personnels pour vous y connecter'+
                   '<table style="margin: 0 auto">' +
                      '<tr>' +
                        '<td style="padding: 0">Nom d\'utilisateur</td>' +
                        '<td style="padding: 0" width=20></td>' +
                        "<td style='padding: 0'><strong>#{user.emails[0].address}</strong></td>" +
                      '</tr>' +
                      '<tr>' +
                        '<td style="padding: 0">Mot de passe</td>' +
                        '<td style="padding: 0" width=20></td>' +
                        "<td style='padding: 0'><strong>#{newPassword}</strong></td>" +
                      '</tr>' +
                   '</table>' +
                   '<br />' +
                   '<div style="text-align: center">' +
                     "Pour vous connecter à la plateforme, <a href='#{loginUrlTo('', user)}'>cliquez-ici</a> " +
                     "ou sur le bouton bleu à la fin de cet e-mail." +
                   '</div>' +
                   '<br />' +
                   '<div style="text-align: center">' +
                     "Vous pourrez vous connecter en cliquant sur le bouton \"Connexion\" " +
                     "puis en remplissant votre nom d'utilisateur et votre mot de passe, comme dans l'exemple ci-dessous.<br />" +
                     "<strong>Il est important de respecter les majuscules et minuscules.</strong><br /><br />" +
                     "<img src='#{Meteor.absoluteUrl('sign_in_demo.gif')}' /><br /><br />" +
                     "Si vous préférez choisir vous-même votre mot de passe, une fois connecté vous pourrez le modifier en " +
                     "cliquant sur votre nom en haut à droite puis sur \"Changer mon mot de passe\", comme dans l'exemple ci-dessous.<br /><br />" +
                     "<img src='#{Meteor.absoluteUrl('change_password_demo.gif')}' />" +
                   '</div>'
          buttonUrl: loginUrlTo('', user)
          buttonText: "Me connecter à la plateforme"
        html = PrettyEmail.render 'call-to-action', options
        mailgun().send
          to: email
          from: 'Planning Maison 24 <planning@lamaison24.fr>'
          subject: 'Vos informations de connexion'
          html: html
  updatePassword: (userId, password) ->
    Accounts.setPassword(userId, password, logout: false)
  confirmUser: (userId) ->
    confirmUser(userId)
  confirmUserAndSendWelcomeEmail: (userId) ->
    confirmUser(userId)
    user = Meteor.users.findOne(userId)
    email = user.emails[0].address
    options = _.extend {},
      heading: "Bonjour #{user.profile.firstname}"
      headingSmall: "<br />Et bienvenue dans l'outil de gestion des plannings de La Maison 24"
      message: '<div style="text-align: center">' +
                 'Nous venons de confirmer votre inscription.<br /><br />' +
                 'Vous pouvez maintenant vous connecter à la plateforme en ' +
                 'cliquant sur le bouton ci-dessous.' +
               '</div>'
      buttonUrl: loginUrlTo('', user)
      buttonText: 'Me connecter à la plateforme'
    html = PrettyEmail.render 'call-to-action', options
    mailgun().send
      to: email
      from: 'Planning Maison 24 <planning@lamaison24.fr>'
      subject: 'Bienvenue !'
      html: html

sendNewUserToConfirmEmailTo = (responsable_inscription, user) ->
  email = responsable_inscription.emails[0].address
  options = _.extend {},
    heading: "Bonjour #{responsable_inscription.profile.firstname}"
    headingSmall: "<br />Un nouveau bénévole vient de s'inscrire sur la plateforme :<br />" +
                  "#{user.profile.firstname} #{user.profile.lastname} (#{user.emails[0].address})"
    message: '<div style="text-align: center">' +
               'Pour valider ou refuser son inscription, cliquez sur le bouton bleu ci-dessous.<br /><br />' +
               "<img src='#{Meteor.absoluteUrl('admin_confirm_user_demo.gif')}' style='width: 100%' />" +
             '</div>'
    buttonUrl: loginUrlTo('users')
    buttonText: "Accéder à la liste des bénévoles"
  html = PrettyEmail.render 'call-to-action', options
  mailgun().send
    to: email
    from: 'Planning Maison 24 <planning@lamaison24.fr>'
    subject: 'Nouvelle inscription'
    html: html

Accounts.onCreateUser (options, user) ->
  user.profile = options.profile if options.profile # Default onCreateUser code from accounts-base.js
  if responsable_inscription = Meteor.users.findOne('profile.lastname': 'Frere')
    sendNewUserToConfirmEmailTo(responsable_inscription, user)
  user
