## reactive-planning

A small Meteor & React app to help build plannings

**If you are interested by this project please file an issue to let me know
and I'll make the necessary work to remove any client-specific code so we
can work together.**

### Installation

Just run `meteor`

### SMS

En se basant sur le planning de Juin on serait arrivé à 9,40€ pour envoyer un
SMS à chacun des participants la veille de chaque jour de distribution.

### TODO

#### Urgent
- Le téléchargement du planning marche pas sur http://planning.lamaison24.fr/planning/juillet-2015
- Re-limiter la hauteur du tableau pour toujours voir la barre de scroll en bas.
- Pouvoir ré-ordonner les colonnes des tâches
- Pouvoir ré-ordonner les lignes des jours
- THEAD toujours visible

#### Suggestions

* Anne - Pourquoi que Mesnard ? Y'a 4 boulangeries
* Anne-Marie : Attacher un message perso sur les disponibilités

#### BUGS

* Invalid character in IE. See https://github.com/ongoworks/meteor-speakingurl/issues/7
* Emailisfake not working ?
* Changer l'API key de Nexmo et l'extraire du code pour la mettre dans une variable d'environnement

#### Nice to have

* Ajouter un message personnalisable par personne
* Permettre de se connecter soit avec l'email soit avec le username
* Ignorer la casse dans le username au login
* Débugger le "Modifier les rôles" et utiliser les rôles définis pour ordonner les personnes dans la modal d'ajout d'une tâche
* Envoyer les emails dans un background job : https://github.com/vsivsi/meteor-job-collection
* Faire que les Days soient vraiment des dates et non des strings pour pouvoir faire des choses en fonction de leur date et heure
* Remplacer `reactjs:react` par `grove:react` : https://forums.meteor.com/t/a-better-package-for-integrating-with-react-grove-react/2225
* Cronjob pour envoyer un SMS les jours de collecte quelques heures avant à tous les concernés.
* Bouton "renvoyer la demande" pour ceux qui n'ont pas répondu
* Bouton "Envoyer un message à tous"
* Remplacer les 'confirm' par http://ethaizone.github.io/Bootstrap-Confirmation/#
* Penser à des alertes pour l'admin, par exemple :
  * Si des cases sont vides X jours avant l'event
  * Quand quelqu'un refuse => beaucoup de mail, faire un récap journalier, hebdomadaire. Est-ce nécessaire ?
* Add proper restrictions for non-admin users
