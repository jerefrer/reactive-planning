Schemas = {};

Template.registerHelper("Schemas", Schemas);

Schemas.UserProfile = new SimpleSchema({
  firstname: {
    type: String,
    label: 'Prénom'
  },
  phone: {
    type: String,
    label: 'Téléphone'
  },
});

Schemas.User = new SimpleSchema({
  username: {
    type: String,
    label: 'Nom complet'
  },
  email: {
    type: String,
    label: 'E-mail',
    regEx: SimpleSchema.RegEx.Email
  },
  profile: {
    type: Schemas.UserProfile
  },
});

var Collections = {};

Template.registerHelper("Collections", Collections);

Users = Collections.Users = Meteor.users;
Users.attachSchema(Schemas.User);

Template.Users.events({
  'click button.addUser': function(event) {
    Session.set("selectedUserId", null);
    setTimeout(function() {
      AutoForm.resetForm('userForm');
    }, 100);
  },
  'click tbody > tr': function (event) {
    var dataTable = $(event.target).closest('table').DataTable();
    var user = dataTable.row(event.currentTarget).data();
    Session.set("selectedUserId", user._id);
  }
});

var userIsSelected = function() {
  return !!Session.get("selectedUserId");
}

Template.Users.helpers({
  userIsSelected: function() {
    return userIsSelected();
  }
})

Template.UserForm.helpers({
  formType: function() {
    return userIsSelected() ? 'update' : 'insert';
  },
  selectedUser: function() {
    return Users.findOne(Session.get("selectedUserId"));
  },
  userIsSelected: function() {
    return userIsSelected();
  }
});
