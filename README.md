## reactive-planning

A small Meteor & React app to help build plannings

#### Objectif

L'app doit être accessible par le plus grand nombre quelque soient leurs
competences techniques ou l'ancienneté de leurs materiels.

### Installation

Just run `meteor`

### Important

Currently the app doesn't work with IE if the JS is minified.
To prevent this, edit meteor-tools' `bundler.js` to disable minifying:
```
nano /home/jeremy/.meteor/packages/meteor-tool/.1.0.44.1msxoe8++os.linux.x86_64+web.browser+web.cordova/mt-os.linux.x86_64/tools/bundler.js
# Replace line 507 with
if (false) { //(options.minify) {
```

### Déployer l'application

```
# En local
deb-mup deploy
```

### Tâches courantes

#### Modifier le modèle d'une semaine

Modifier `weeklyEvents` dans server/planning.coffee puis pusher et déployer.

#### Ajouter une personne en tant que administrateur

docs/set_someone_as_admin_on_prod

#### Modifier le responsable de la validation des inscriptions

Modifier la variable email dans la methode: `sendNewUserToConfirmEmailTo` dans
le fichier server/users.coffee (tout en bas)
