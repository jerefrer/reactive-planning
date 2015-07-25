userPresentForDay = (planning, day) ->
  !!_.find planning.presences, (dutiesForDay, key) ->
    key.split(',')[0] == day._id and dutiesForDay.find (duty) -> duty._id == Meteor.userId()

buildEvents = (planning) ->
  planning.days.map (day) =>
    date: day.date
    id: day._id
    present: userPresentForDay(planning, day)

Template.UserPresence.rendered = ->
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
                         <% var events = days[d].events %>
                         <td class="<%= days[d].classes %> <% if (events.length == 1) { %>with-one-event<% } else if (events.length > 1) { %>with-multiple-events<% } %>">
                           <div class="day-number"><%= days[d].day %></div>
                           <% _.each(events, function(event, index) { %>
                             <div class="checkbox" data-day-id="<%= event.id %>">
                               <% if (events.length > 1) { %>
                                 <div class="detail">
                                   <% if (index == 0) { %>
                                     Matin
                                   <% } else { %>
                                     Soir
                                   <% } %>
                                 </div>
                               <% } %>
                               <% if (event.present) { %>
                                 <i class="fa fa-check-square-o text-success" />
                               <% } else { %>
                                 <i class="fa fa-square-o text-muted" />
                               <% } %>
                             </div>
                           <% }); %>
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
    events: buildEvents(@data.planning)
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
    dayId = $(event.currentTarget).data('day-id')
    Meteor.call 'togglePresence', @planning._id, dayId, Meteor.userId()
