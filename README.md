## reactive-planning

A small Meteor & React app to help build plannings

**If you are interested by this project please file an issue to let me know
and I'll make the necessary work to remove any client-specific code so we
can work together.**

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
mup deploy
```

### Tâches courantes

#### Modifier le modèle d'une semaine

Modifier `weeklyEvents` dans server/planning.coffee puis pusher et déployer.

####
