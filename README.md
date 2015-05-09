## reactive-planning

A small Meteor & React app to help build plannings

**If you are interested by this project please file an issue to let me know
and I'll make the necessary work to remove any client-specific code so we
can work together.**

### Installation

Just run `meteor`

### TODO

#### Needed before launch

* On ajoute un bouton "Envoyer les emails des mots de passe" qui envoie un email avec un mot de passe auto-généré à chaque utilisateur qui ne l'a pas déjà (ajouter un boolean) en invitant l'utilisateur à le changer immédiatement
* Ajouter un bouton sur une fiche user "renvoyer l'email de mot de passe".

#### Nice to have

* Faire que les Days soient vraiment des dates et non des strings pour pouvoir faire des choses en fonction de leur date et heure
* Cronjob pour envoyer un SMS les jours de collecte quelques heures avant à tous les concernés.
* Bouton "renvoyer la demande" pour ceux qui n'ont pas répondu
* Bouton "Envoyer un message à tous"
* Penser à des alertes pour l'admin, par exemple :
  * Si des cases sont vides X jours avant l'event
  * Quand quelqu'un refuse => beaucoup de mail, faire un récap journalier, hebdomadaire. Est-ce nécessaire ?
* Add proper restrictions for non-admin users
