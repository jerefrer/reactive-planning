moment.locale('fr')

@Plannings = new Meteor.Collection('plannings')

Tracker.autorun ->
  Meteor.subscribe 'users'

Router.plugin 'auth'

Router.onBeforeAction 'authorize',
  authorize:
    allow: -> !!Meteor.user().active
    template: 'NotActivated'
  except: ['login', 'EditProfile']

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
  data: ->
    planning: Plannings.findOne(slug: @params.slug)
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
  data: ->
    planning: Plannings.findOne(slug: @params.slug)
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
  action: ->
    planning = Plannings.findOne(slug: @params.slug)
    @render 'UserPresence'
    setTimeout (->
      if planning.unavailableTheWholeMonth.indexOf(Meteor.userId()) >= 0
        $('#user-presence-calendar').append('<div class="inactive-overlay"></div>')
    ), 100

Router.route 'UsersPresences',
  path: '/planning/:slug/admin/presences'
  waitOn: ->
    Meteor.subscribe 'plannings'
  action: ->
    planning = Plannings.findOne(slug: @params.slug)
    users = sortUsers(Meteor.users.find().fetch())
    @render 'UsersPresences'
    setTimeout (->
      React.render(
        <UsersPresences planning={planning} users={users} />,
        document.getElementById('users-presences')
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
  action: ->
    @render 'Users'
    setTimeout (->
      if $('#sendPasswordEmailsButton').length
        React.render(
          <SendPasswordEmailsButton />,
          document.getElementById('sendPasswordEmailsButton')
        )
    ), 200

Router.route 'EditProfile',
  path: '/modifier-mon-profil'

Router.route 'login',
  path: '/connectez-vous'
