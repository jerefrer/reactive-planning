generateEmailLoginToken = (user) ->
  tokenRecord =
    token: Random.secret()
    address: user.emails[0].address
    when: new Date()
  Meteor.users.update(
    { _id: user._id },
    { $push: {'services.email.verificationTokens': tokenRecord } }
  )
  Meteor._ensure(user, 'services', 'email')
  if (!user.services.email.verificationTokens)
    user.services.email.verificationTokens = []
  user.services.email.verificationTokens.push(tokenRecord)
  tokenRecord.token

emailLoginTokenFor = (user) ->
  if tokenRecord = user.services.email.verificationTokens.first()
    tokenRecord.token
  else
    generateEmailLoginToken(user)

@loginUrlTo = (url, user) ->
  Meteor.absoluteUrl("#{url}/#/login/#{emailLoginTokenFor(user)}")
