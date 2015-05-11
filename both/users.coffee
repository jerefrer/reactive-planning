@usersWithoutPassword = ->
  Meteor.users.find($or: [ {passwordEmailSent: false},
                           {passwordEmailSent: {$exists: false}} ]).fetch()
