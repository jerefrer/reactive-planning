Router.plugin('auth');

Router.configure({
  layoutTemplate: 'Layout',
  loadingTemplate: 'Loading',
  notFoundTemplate: 'NotFound',
});
Router.onBeforeAction('loading');

Router.route('Home', { path: '/' });
Router.route('Plannings', {
  path: '/plannings',
  waitOn: function () {
    return Meteor.subscribe('plannings');
  },
  data: {
    plannings: function() { return Plannings.find().fetch() }
  }
});
Router.route('Planning', {
  path: '/planning/:slug/admin',
  waitOn: function () {
    return Meteor.subscribe('plannings');
  },
  action: function () {
    var planning = Plannings.findOne({slug: this.params.slug});
    Session.set('currentPlanning', planning);
    this.render('Planning', {planning: planning});
    setTimeout(function() {
      React.render(
        <Scheduler planning={planning} />,
        document.getElementById('planning')
      );
    }, 100);
  }
});
Router.route('UserPlanning', {
  path: '/planning/:slug',
  waitOn: function () {
    return Meteor.subscribe('plannings');
  },
  action: function () {
    var planning = Plannings.findOne({slug: this.params.slug});
    Session.set('currentPlanning', planning);
    this.render('Planning', {planning: planning});
    setTimeout(function() {
      React.render(
        <UserPlanning planning={planning} />,
        document.getElementById('planning')
      );
    }, 100);
  }
});
Router.route('ConfirmDuty', {
  path: '/planning/:slug/confirm/:dayId/:taskId/:personId',
  waitOn: function () {
    return Meteor.subscribe('plannings');
  },
  action: function () {
    Meteor.call('answerNotification', this.params.slug, this.params.dayId, this.params.taskId, this.params.personId, true);
    this.render('ConfirmDuty');
  }
});
Router.route('DeclineDuty', {
  path: '/planning/:slug/decline/:dayId/:taskId/:personId',
  waitOn: function () {
    return Meteor.subscribe('plannings');
  },
  action: function () {
    Meteor.call('answerNotification', this.params.slug, this.params.dayId, this.params.taskId, this.params.personId, false);
    this.render('DeclineDuty');
  }
});
