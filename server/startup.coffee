initializeTasks = ->
  ['Banque alimentaire',
   'Médiateur, responsable d\'équipe' ,
   'Chercher pain Mesnard'
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

generatePassword = ->
  Math.random().toString(10).substr(2, 5)

Meteor.startup ->
  if Tasks.find().fetch().length == 0
    initializeTasks()

  if Meteor.users.find().fetch().length == 0
    days = [
      {_id: guid(), name: 'Vendredi 3',  date: moment('03-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 4',    date: moment('04-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 5',  date: moment('05-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 10', date: moment('10-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 11',   date: moment('11-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 12', date: moment('12-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 17', date: moment('17-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 18',   date: moment('18-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 19', date: moment('19-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 24', date: moment('24-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 25',   date: moment('25-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 26', date: moment('26-07-2015', 'DD-MM-YYYY').toDate() }
    ]
    Meteor.call 'createPlanning', 6, 2015, days
    Meteor.call 'createPlanning', 7, 2015, []

    csv_text = Assets.getText('export_benevoles.csv')
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

    Meteor.users.update {username: 'Jérémy Frère'}, {$set: {username: 'Jérémy Frere', passwordEmailSent: true}}
    jeremy = Meteor.users.findOne('profile.firstname': 'Jérémy')
    Accounts.setPassword jeremy._id, 'canada', logout: false
    Roles.addUsersToRoles jeremy, ['admin']
    Roles.addUsersToRoles Meteor.users.findOne(username: 'Odile LM24'), ['admin']
    Roles.addUsersToRoles Meteor.users.findOne(username: 'Palzang'), ['admin']
