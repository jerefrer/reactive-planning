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
  passwordEmailSent:
    type: Boolean
    label: 'A reçu un e-mail avec son mot de passe ? Mettre à non pour regénérer un mot de passe et le renvoyer par email au prochain clic sur "Envoyer les mots de passe"'
    optional: true

Collections = {}
Template.registerHelper 'Collections', Collections
@Users = Collections.Users = Meteor.users
@Users.attachSchema Schemas.User
