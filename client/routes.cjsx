Router.plugin 'auth'
Router.configure
  layoutTemplate: 'Layout'
  loadingTemplate: 'Loading'
  notFoundTemplate: 'NotFound'
Router.onBeforeAction 'loading'

Router.route 'Home', path: '/'

Router.route 'Plannings',
  path: '/plannings'
  waitOn: ->
    Meteor.subscribe 'plannings'
  action: ->
    plannings = Plannings.find().fetch()
    @render 'PlanningsList'
    setTimeout (->
      React.render(
        <PlanningsList plannings={plannings} />,
        document.getElementById('plannings-list')
      )
    ), 100

Router.route 'Planning',
  path: '/planning/:slug/admin'
  waitOn: ->
    Meteor.subscribe 'plannings'
  action: ->
    planning = Plannings.findOne(slug: @params.slug)
    Session.set 'currentPlanning', planning
    @render 'Planning', planning: planning
    setTimeout (->
      React.render(
        <Scheduler planning={planning} />,
        document.getElementById('planning')
      )
    ), 100

Router.route 'UserPresence',
  path: '/planning/:slug'
  waitOn: ->
    Meteor.subscribe 'plannings'
  action: ->
    planning = Plannings.findOne(slug: @params.slug)
    Session.set 'currentPlanning', planning
    @render 'Planning', planning: planning
    setTimeout (->
      React.render(
        <UserPresence planning={planning} />,
        document.getElementById('planning')
      )
    ), 100

Router.route 'UsersPresence',
  path: '/planning/:slug/presences'
  waitOn: ->
    Meteor.subscribe 'plannings'
  action: ->
    planning = Plannings.findOne(slug: @params.slug)
    Session.set 'currentPlanning', planning
    @render 'Planning', planning: planning
    setTimeout (->
      React.render(
        <UsersPresence planning={planning} />,
        document.getElementById('planning')
      )
    ), 100

Router.route 'ConfirmDuty',
  path: '/planning/:slug/confirm/:dayId/:taskId/:personId'
  waitOn: ->
    Meteor.subscribe 'plannings'
  action: ->
    Meteor.call 'answerNotification', @params.slug, @params.dayId, @params.taskId, @params.personId, true
    @render 'ConfirmDuty'

Router.route 'DeclineDuty',
  path: '/planning/:slug/decline/:dayId/:taskId/:personId'
  waitOn: ->
    Meteor.subscribe 'plannings'
  action: ->
    Meteor.call 'answerNotification', @params.slug, @params.dayId, @params.taskId, @params.personId, false
    @render 'DeclineDuty'

Router.route 'Users',
  path: '/users'
  waitOn: ->
    Meteor.subscribe 'users'
