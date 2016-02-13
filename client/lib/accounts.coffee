accountsUIBootstrap3.setLanguage('fr')

Accounts.ui.config
  passwordSignupFields: 'USERNAME_AND_EMAIL'
  requestPermissions: {}
  extraSignupFields: [
    fieldName: 'firstname'
    fieldLabel: 'Prénom'
    inputType: 'text'
    visible: true
    validate: (value, errorFunction) ->
      return true if value
      errorFunction "Veuillez entrer votre prénom"
      return false
  ,
    fieldName: 'lastname'
    fieldLabel: 'Nom'
    inputType: 'text'
    visible: true
    validate: (value, errorFunction) ->
      return true if value
      errorFunction "Veuillez entrer votre nom"
      return false
  ,
      fieldName: 'phone'
      fieldLabel: 'Téléphone'
      inputType: 'text'
      visible: true
  ,
      fieldName: 'address'
      fieldLabel: 'Adresse'
      inputType: 'text'
      visible: true
  ,
      fieldName: 'postal_code'
      fieldLabel: 'Code Postal'
      inputType: 'text'
      visible: true
  ,
      fieldName: 'city'
      fieldLabel: 'Ville'
      inputType: 'text'
      visible: true
  ]
