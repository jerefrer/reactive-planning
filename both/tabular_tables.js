TabularTables = {};

Meteor.isClient && Template.registerHelper('TabularTables', TabularTables);

TabularTables.Users = new Tabular.Table({
  name: "Users",
  collection: Meteor.users,
  extraFields: ['passwordEmailSent'],
  responsive: true,
  autoWidth: false,
  columns: [
    {data: "username", title: "Nom"},
    {data: "emails[0].address", title: "E-mail", render: function (email, type, doc) {
      var string = email;
      if (!doc.passwordEmailSent && !Session.get('showInactiveUsers')) string += ' <i class="fa fa-envelope">';
      return string;
    }},
    {data: "profile.phone", title: "Téléphone"},
    {data: "createdAt", title: "Ajouté le", render: function(date, type, doc) { return moment(date).format('DD-MM-YYYY à HH:SS') } }
  ],
  info:     false,
  pageLength: 50,
  language: {
    "sProcessing":     "Traitement en cours...",
    "sSearch":         "Rechercher&nbsp;:",
    "sLengthMenu":     "_MENU_ par page",
    "sInfo":           "Affichage de l'&eacute;lement _START_ &agrave; _END_ sur _TOTAL_ &eacute;l&eacute;ments",
    "sInfoEmpty":      "Affichage de l'&eacute;lement 0 &agrave; 0 sur 0 &eacute;l&eacute;ments",
    "sInfoFiltered":   "(filtr&eacute; de _MAX_ &eacute;l&eacute;ments au total)",
    "sInfoPostFix":    "",
    "sLoadingRecords": "Chargement en cours...",
    "sZeroRecords":    "Aucun &eacute;l&eacute;ment &agrave; afficher",
    "sEmptyTable":     "Aucune donn&eacute;e disponible dans le tableau",
    "oPaginate": {
        "sFirst":      "Premier",
        "sPrevious":   "Pr&eacute;c&eacute;dent",
        "sNext":       "Suivant",
        "sLast":       "Dernier"
    },
    "oAria": {
        "sSortAscending":  ": activer pour trier la colonne par ordre croissant",
        "sSortDescending": ": activer pour trier la colonne par ordre d&eacute;croissant"
    }
  }
});
