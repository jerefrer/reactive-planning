$.fn.datepicker.dates['fr'] =
  days: ["Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"]
  daysShort: ["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"]
  daysMin: ["Di", "Lu", "Ma", "Me", "Je", "Ve", "Sa"]
  months: ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
  monthsShort: ["Jan", "Fév", "Mar", "Avr", "Mai", "Juin", "Juil", "Aoû", "Sep", "Oct", "Nov", "Déc"]
  today: "Aujourd'hui"
  clear: "Effacer"

Template.PlanningAdmin.events
  'click .downloadPlanning': ->
    downloadPlanning(@planning)
