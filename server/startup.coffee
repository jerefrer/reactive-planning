initializeTasks = ->
  ['Vesuna',
   'Entretiens individuels',
   'Camion Plazac',
   'Banque alimentaire',
   'Médiateur, responsable d\'équipe' ,
   'Chercher pain',
   'Ramasse Carrefour Market',
   'Préparer soupe',
   'Amener soupe',
   'Camion',
   'Chargement',
   'Accueil & Distribution',
   'Fourniture comptoir',
   'Servir café & soupe',
   'Déchargement & Vaisselle local',
   'Suppléants'].each (name) ->
    Tasks.insert name: name

importDump = ->
  csv_text = Assets.getText('export_benevoles_test.csv')
  Papa.parse csv_text,
    header: true
    skipEmptyLines: true
    delimiter: ';'
    encoding: "UTF-8"
    step: (row) ->
      data = row.data[0]
      email = data['Email'].split(';')[0].trim()
      email = null if Meteor.users.find({'emails.address': email}).count() > 0
      Accounts.createUser
        username: [(data['Prénom'] + '').trim(), (data['Nom'] + '').trim()].join(' ').trim()
        email: email || "#{generatePassword()}@fakemail.com"
        password: generatePassword()
        profile:
          firstname: (data['Prénom'] + '').trim()
          lastname: (data['Nom'] + '').trim()
          phone: (data['Tél. 1'] + '').trim()
          address: (data['Adresse'] + '').trim()
          postal_code: (data['Code postal'] + '').trim()
          city: (data['Ville'] + '').trim()

generatePassword = ->
  Math.random().toString(10).substr(2, 5)

Meteor.startup ->
  if Tasks.find().fetch().length == 0
    initializeTasks()

  # if Meteor.users.find().fetch().length == 0
  #   importDump()

  if jeremy = Meteor.users.findOne('profile.firstname': 'Jérémy')
    Meteor.users.update {_id: jeremy._id}, {$set: {username: 'Jérémy Frere', passwordEmailSent: true}}
    Accounts.setPassword jeremy._id, 'canada', logout: false
    Roles.addUsersToRoles jeremy, ['admin']

  if palzang = Meteor.users.findOne(username: 'Palzang')
    Roles.addUsersToRoles palzang, ['admin']

  if noemie = Meteor.users.findOne(username: 'noemie maldorane')
    Roles.addUsersToRoles noemie, ['admin']
