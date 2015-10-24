userPresentForDay = (event) ->
  event.availablePeople.indexOf(Meteor.userId()) >= 0

buildEvents = (events) ->
  events.map (event) ->
    Object.extended(event).merge
      present: userPresentForDay(event)

Template.UserPresence.rendered = ->
  startOfMonth = @data.planning.events.first().date
  endOfMonth = @data.planning.events.last().date
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
                         <% var eventsForDayByGroup = events.groupBy("group_id"); %>
                         <% var dayHasEvents = Object.keys(eventsForDayByGroup).length > 0 && days[d].classes.indexOf("inactive") < 0 %>
                         <td class="<%= days[d].classes %> <% if (dayHasEvents) { %>with-events<% } %>">
                           <div class="day-number"><%= days[d].day %></div>
                           <% if (dayHasEvents) { %>
                             <% _.each(eventsForDayByGroup, function(eventsGroup) { %>
                               <div class="group">
                                 <% _.each(eventsGroup, function(event) { %>
                                   <div class="checkbox" data-event-id="<%= event._id %>">
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
    startWithMonth: startOfMonth
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
    events: buildEvents(@data.planning.events)
    showAdjacentMonths: true
    forceSixRows: null
    constraints:
      startDate: startOfMonth
      endDate: endOfMonth
  Plannings.find().observeChanges
    changed: (id) ->
      planning = Plannings.findOne(id)
      user_presence_calendar.setEvents buildEvents(planning.events)

Template.UserPresence.events
  'click #user-presence-calendar .checkbox': (event) ->
    successPopup()
    eventId = $(event.currentTarget).data('event-id')
    Meteor.call 'togglePresence', @planning._id, eventId, Meteor.userId()
