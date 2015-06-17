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
