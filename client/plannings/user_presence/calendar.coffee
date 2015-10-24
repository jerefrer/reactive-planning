userPresentForDay = (planning, day) ->
  !!_.find planning.presences, (dutiesForDay, key) ->
    key.split(',')[0] == day._id and dutiesForDay.find (duty) -> duty._id == Meteor.userId()

@events = [
  { "id":  1, "weekDay": 1, "name": "13:00 - 15:00", "detail": "Chargement",         "required": false, "group_id": 1 },
  { "id":  2, "weekDay": 1, "name": "15:00 - 17:00", "detail": "Distribution colis", "required": false, "group_id": 1 },

  { "id":  3, "weekDay": 2, "name": "17:30 - 18:00", "detail": "Chargement",         "required": false, "group_id": 2 },
  { "id":  4, "weekDay": 2, "name": "18:00 - 19:30", "detail": "Distribution",       "required":  true, "group_id": 2 },
  { "id":  5, "weekDay": 2, "name": "19:30 - 20:30", "detail": "Déchargement",       "required": false, "group_id": 2 },

  { "id":  6, "weekDay": 4, "name": "17:30 - 18:00", "detail": "Chargement",         "required": false, "group_id": 3 },
  { "id":  7, "weekDay": 4, "name": "18:00 - 19:30", "detail": "Distribution",       "required":  true, "group_id": 3 },
  { "id":  8, "weekDay": 4, "name": "19:30 - 20:30", "detail": "Déchargement",       "required": false, "group_id": 3 },

  { "id":  9, "weekDay": 6, "name": "09:00 - 11:00", "detail": "Chargement",         "required": false, "group_id": 4 },
  { "id": 10, "weekDay": 6, "name": "17:30 - 18:00", "detail": "Distribution",       "required": false, "group_id": 4 },
  { "id": 11, "weekDay": 6, "name": "17:30 - 18:00", "detail": "Chargement",         "required": false, "group_id": 5 },
  { "id": 12, "weekDay": 6, "name": "18:00 - 19:30", "detail": "Distribution",       "required":  true, "group_id": 5 },
  { "id": 13, "weekDay": 6, "name": "19:30 - 20:30", "detail": "Déchargement",       "required": false, "group_id": 5 }
]

Template.UserPresence.rendered = ->
  window.weeklyEvents = @data.planning.weeklyEvents
  user_presence_calendar = $('#user-presence-calendar').clndr
    template: '<table class="clndr-table table table-bordered" border="0" cellspacing="0" cellpadding="0">
                 <thead>
                   <tr class="header-days">
                     <% for(var i = 0; i < daysOfTheWeek.length; i++) { %>
                       <td class="header-day"><%= daysOfTheWeek[i] %></td>
                     <% } %>
                   </tr>
                 </thead>
                 <tbody>
                   <% for(var i = 0; i < numberOfRows; i++) { %>
                     <tr>
                       <% for(var j = 0; j < 7; j++) { %>
                         <% var d = j + i * 7; %>
                         <% var eventsForDayByGroup = window.weeklyEvents.findAll({weekDay: j+1}).groupBy("group_id"); %>
                         <% var dayHasEvents = Object.keys(eventsForDayByGroup).length > 0 && days[d].classes.indexOf("inactive") < 0 %>
                         <td class="<%= days[d].classes %> <% if (dayHasEvents) { %>with-events<% } %>">
                           <div class="day-number"><%= days[d].day %></div>
                           <% if (dayHasEvents) { %>
                             <% _.each(eventsForDayByGroup, function(eventsGroup) { %>
                               <div class="group">
                                 <% _.each(eventsGroup, function(event) { %>
                                   <div class="checkbox" data-week-day-id="<%= event.id %>">
                                     <div class="name">
                                       <%= event.name %>
                                       <% if (event.detail) { %>
                                         <span><%= event.detail %></span>
                                       <% } %>
                                     </div>
                                     <% if (event.present) { %>
                                       <i class="fa fa-check-square-o text-success" />
                                     <% } else { %>
                                       <i class="fa fa-square-o text-muted" />
                                     <% } %>
                                   </div>
                                 <% }); %>
                               </div>
                             <% }); %>
                           <% } %>
                         </td>
                       <% } %>
                     </tr>
                   <% } %>
                 </tbody>
               </table>'
    startWithMonth: @data.planning.days.first().date
    weekOffset: 1
    daysOfTheWeek: ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi']
    targets:
      nextButton: 'clndr-next-button'
      previousButton: 'clndr-previous-button'
      nextYearButton: 'clndr-next-year-button'
      previousYearButton: 'clndr-previous-year-button'
      todayButton: 'clndr-today-button'
      day: 'day'
      empty: 'empty'
    classes:
      today: "today"
      event: "event"
      past: "past"
      lastMonth: "last-month"
      nextMonth: "next-month"
      adjacentMonth: "adjacent-month"
      inactive: "inactive"
      selected: "selected"
    showAdjacentMonths: true
    forceSixRows: null
    constraints:
      startDate: moment(@data.planning.days.first().date).startOf('month')
      endDate: moment(@data.planning.days.first().date).endOf('month')
  Plannings.find().observeChanges
    changed: (id) ->
      planning = Plannings.findOne(id)
      user_presence_calendar.setEvents buildEvents(planning)

Template.UserPresence.events
  'click #user-presence-calendar .checkbox': (event) ->
    successPopup()
    weekDayId = $(event.currentTarget).data('week-day-id')
    Meteor.call 'togglePresence', @planning._id, weekDayId, Meteor.userId()
