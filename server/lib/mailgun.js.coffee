@mailgun = ->
  options =
    apiKey: 'key-53e598497990b587981fb538556d929e'
    domain: 'sandboxcca7022b53aa489587e322ab0380c2ae.mailgun.org'
  new Mailgun(options)
