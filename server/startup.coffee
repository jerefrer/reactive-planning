initializeTasks = ->
  ['Banque alimentaire',
   'Médiateur, responsable d\'équipe' ,
   'Chercher pain'
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
      {_id: guid(), name: 'Vendredi 1er', date: moment('01-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 2',     date: moment('02-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 3',   date: moment('03-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 8',   date: moment('08-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 9',     date: moment('09-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 10',  date: moment('10-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 15',  date: moment('15-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 16',    date: moment('16-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 17',  date: moment('17-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 22',  date: moment('22-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 23',    date: moment('23-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 24',  date: moment('24-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 29',  date: moment('29-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 30',    date: moment('30-05-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 31',  date: moment('31-05-2015', 'DD-MM-YYYY').toDate() }
    ]
    Meteor.call 'createPlanning', 5, 2015, days
    Meteor.call 'createPlanning', 6, 2015, []

    csv_text = Assets.getText('export_benevoles.csv')
    Papa.parse csv_text,
      header: true
      skipEmptyLines: true
      delimiter: ';'
      step: (row) ->
        data = row.data[0]
        Accounts.createUser
          username: data['Prénom'] + ' ' + data['Nom']
          email: data['Emails'].split(';')[0] || "#{generatePassword()}@fakemail.com"
          password: generatePassword()
          profile:
            firstname: data['Prénom']
            phone: data['Tél. 1']
            adresse: data['Adresse']
            code_postal: data['Code postal']
            ville: data['Ville']

    Meteor.users.update {username: 'Jérémy Frère'}, {$set: {username: 'Jérémy Frere', admin: true, passwordEmailSent: true}}
    jeremy = Meteor.users.find({"profile.firstname": "Jérémy"}).fetch()[0];
    Accounts.setPassword jeremy._id, 'canada', logout: false
    Roles.addUsersToRoles(jeremy, ["admin"]);
