moment.locale('fr')

@Plannings = new Meteor.Collection('plannings')

Router.plugin 'auth'

Router.configure
  layoutTemplate: 'Layout'
  loadingTemplate: 'Loading'
  notFoundTemplate: 'NotFound'
Router.onBeforeAction 'loading'

Router.route 'Dashboard',
  path: '/'
  waitOn: ->
    Meteor.subscribe 'plannings'
  action: ->
    plannings = Plannings.find().fetch()
    @render 'Dashboard'
    setTimeout (->
      React.render(
        <Dashboard plannings={plannings} />,
        document.getElementById('dashboard')
      )
    ), 100

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
  path: '/planning/:slug'
  waitOn: ->
    Meteor.subscribe 'plannings'
  action: ->
    planning = Plannings.findOne(slug: @params.slug)
    @render 'Planning'
    setTimeout (->
      React.render(
        <Planning planning={planning} />,
        document.getElementById('planning')
      )
    ), 100

Router.route 'PlanningAdmin',
  path: '/planning/:slug/admin'
  waitOn: ->
    Meteor.subscribe 'plannings'
  action: ->
    planning = Plannings.findOne(slug: @params.slug)
    @render 'PlanningAdmin'
    setTimeout (->
      React.render(
        <PlanningAdmin planning={planning} />,
        document.getElementById('planning-admin')
      )
    ), 100

Router.route 'UserPresence',
  path: '/planning/:slug/presences'
  waitOn: ->
    Meteor.subscribe 'plannings'
  data: ->
    planning: Plannings.findOne(slug: @params.slug)
    slug: @params.slug

Router.route 'UsersPresence',
  path: '/planning/:slug/admin/presences'
  action: ->
    planning = Plannings.findOne(slug: @params.slug)
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
  action: ->
    @render 'Users'
    setTimeout (->
      React.render(
        <SendPasswordEmailsButton />,
        document.getElementById('sendPasswordEmailsButton')
      )
    ), 100

Router.route 'login',
  path: '/connectez-vous'
