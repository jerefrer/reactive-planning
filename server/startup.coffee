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

generatePassword = ->
  Math.random().toString(10).substr(2, 5)

Meteor.startup ->
  if Tasks.find().fetch().length == 0
    initializeTasks()

  if Meteor.users.find().fetch().length == 0
    julyDays = [
      {_id: guid(), name: 'Jeudi 2',     date: moment('02-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 3',  date: moment('03-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 4',    date: moment('04-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 5',  date: moment('05-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Lundi 6',     date: moment('06-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Mardi 7',     date: moment('07-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Jeudi 9',     date: moment('09-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 10', date: moment('10-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 11',   date: moment('11-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 12', date: moment('12-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Lundi 13',    date: moment('13-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Mardi 14',    date: moment('14-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Jeudi 16',    date: moment('16-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 17', date: moment('17-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 18',   date: moment('18-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 19', date: moment('19-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Lundi 20',    date: moment('20-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Mardi 21',    date: moment('21-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Jeudi 23',    date: moment('23-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 24', date: moment('24-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 25',   date: moment('25-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 26', date: moment('26-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Lundi 27',    date: moment('27-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Mardi 28',    date: moment('28-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Jeudi 30',    date: moment('30-07-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 31', date: moment('31-07-2015', 'DD-MM-YYYY').toDate() }
    ]
    augustDays = [
      {_id: guid(), name: 'Samedi 1',    date: moment('01-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 2',  date: moment('02-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Lundi 3',     date: moment('03-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Mardi 4',     date: moment('04-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Jeudi 6',     date: moment('06-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 7',  date: moment('07-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 8',    date: moment('08-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 9',  date: moment('09-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Lundi 10',    date: moment('10-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Mardi 11',    date: moment('11-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Jeudi 13',    date: moment('13-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 14', date: moment('14-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 15',   date: moment('15-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 16', date: moment('16-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Lundi 17',    date: moment('17-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Mardi 18',    date: moment('18-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Jeudi 20',    date: moment('20-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 21', date: moment('21-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 22',   date: moment('22-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 23', date: moment('23-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Lundi 24',    date: moment('24-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Mardi 25',    date: moment('25-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Jeudi 27',    date: moment('27-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 28', date: moment('28-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 29',   date: moment('29-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 30', date: moment('30-08-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Lundi 31',    date: moment('31-08-2015', 'DD-MM-YYYY').toDate() }
    ]
    septemberDays = [
      {_id: guid(), name: 'Mardi 1',     date: moment('01-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Jeudi 3',     date: moment('03-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 4',  date: moment('04-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 5',    date: moment('05-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 6',  date: moment('06-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Lundi 7',     date: moment('07-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Mardi 8',     date: moment('08-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Jeudi 11',    date: moment('11-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 11', date: moment('11-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 12',   date: moment('12-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 13', date: moment('13-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Lundi 14',    date: moment('14-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Mardi 15',    date: moment('15-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Jeudi 17',    date: moment('17-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 18', date: moment('18-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 19',   date: moment('19-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 20', date: moment('20-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Lundi 21',    date: moment('21-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Mardi 22',    date: moment('22-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Jeudi 24',    date: moment('24-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Vendredi 25', date: moment('25-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Samedi 26',   date: moment('26-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Dimanche 27', date: moment('27-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Lundi 28',    date: moment('28-09-2015', 'DD-MM-YYYY').toDate() }
      {_id: guid(), name: 'Mardi 29',    date: moment('29-09-2015', 'DD-MM-YYYY').toDate() }
    ]

    Meteor.call 'createPlanning', 6, 2015, julyDays
    Meteor.call 'createPlanning', 7, 2015, augustDays
    Meteor.call 'createPlanning', 8, 2015, septemberDays

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

  if jeremy = Meteor.users.findOne('profile.firstname': 'Jérémy')
    Meteor.users.update {_id: jeremy._id}, {$set: {username: 'Jérémy Frere', passwordEmailSent: true}}
    Accounts.setPassword jeremy._id, 'canada', logout: false
    Roles.addUsersToRoles jeremy, ['admin']
  if odile = Meteor.users.findOne(username: 'Odile D')
    Meteor.users.update {_id: odile._id}, {$set: {passwordEmailSent: true}}
    Roles.addUsersToRoles odile, ['admin']
  if palzang = Meteor.users.findOne(username: 'Palzang')
    Roles.addUsersToRoles palzang, ['admin']
  if noemie = Meteor.users.findOne(username: 'noemie maldorane')
    Roles.addUsersToRoles noemie, ['admin']
