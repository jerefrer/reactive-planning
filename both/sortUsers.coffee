@sortUsers = (users) ->
  _.sortBy users, (user) ->
    (user.profile.firstname || '') + (user.profile.lastname || '')
