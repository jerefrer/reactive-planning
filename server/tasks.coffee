Meteor.methods
  addUserPreferedTask: (userId, taskId, removeFromOtherList) ->
    user = Meteor.users.findOne(userId)
    preferedTasks = user.preferedTasks || []
    if !preferedTasks.find(_id: taskId)
      preferedTasks.push _id: taskId
      Meteor.users.update userId, $set: preferedTasks: preferedTasks
      Meteor.call('removeUserBannedTask', userId, taskId) if removeFromOtherList
  removeUserPreferedTask: (userId, taskId) ->
    user = Meteor.users.findOne(userId)
    preferedTasks = user.preferedTasks || []
    preferedTasks.remove _id: taskId
    Meteor.users.update userId, $set: preferedTasks: preferedTasks
  addUserBannedTask: (userId, taskId, removeFromOtherList) ->
    user = Meteor.users.findOne(userId)
    bannedTasks = user.bannedTasks || []
    if !bannedTasks.find(_id: taskId)
      bannedTasks.push _id: taskId
      Meteor.users.update userId, $set: bannedTasks: bannedTasks
      Meteor.call('removeUserPreferedTask', userId, taskId) if removeFromOtherList
  removeUserBannedTask: (userId, taskId) ->
    user = Meteor.users.findOne(userId)
    bannedTasks = user.bannedTasks || []
    bannedTasks.remove _id: taskId
    Meteor.users.update userId, $set: bannedTasks: bannedTasks
