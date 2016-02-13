Schemas = {}
Template.registerHelper 'Schemas', Schemas
Schemas.UserProfile = new SimpleSchema
  firstname:
    type: String
    label: 'Prénom'
  lastname:
    type: String
    label: 'Nom'
    optional: true
  phone:
    type: String
    label: 'Téléphone'
    optional: true
  address:
    type: String
    label: 'Adresse'
    optional: true
  postal_code:
    type: String
    label: 'Code postal'
    optional: true
  city:
    type: String
    label: 'Ville'
    optional: true
Schemas.User = new SimpleSchema
  username:
    type: String
    label: "Nom d'utilisateur"
  emails:
    type: [Object]
  "emails.$.address":
    type: String
    regEx: SimpleSchema.RegEx.Email
    autoform:
      label: false
  profile:
    type: Schemas.UserProfile

SimpleSchema.messages
  "required emails": "L'email doit être rempli. Si la personne n'a pas d'email, il faut lui mettre un email du type prenom_nom@fakemail.com. Le fait que l'email se termine par @fakemail.com est très important car il permet d'éviter qu'on envoie de vrais emails à cette adresse. Merci de respecter ça !"

Collections = {}
Template.registerHelper 'Collections', Collections
@Users = Collections.Users = Meteor.users
@Users.attachSchema Schemas.User
