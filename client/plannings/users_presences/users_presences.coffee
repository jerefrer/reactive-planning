hasAnswered = (planning, user) ->
  planning.peopleWhoAnswered.indexOf(user._id) >= 0

Template.userWithAnsweredState.helpers
  answeredClass: ->
    hasAnswered(@parentContext.planning, @user) && 'selected' || ''
  displayName: ->
    displayName(@user)
