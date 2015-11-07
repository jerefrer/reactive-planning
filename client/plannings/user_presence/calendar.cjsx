userPresentForDay = (event) ->
  event.availablePeople.indexOf(Meteor.userId()) >= 0

buildEvents = (events) ->
  events.map (event) ->
    Object.extended(event).merge
      present: userPresentForDay(event)

addAvailabilitiesDisabledMessage = ->
  if moment().date() < 10
    title = "<img src='/later.png' /><span>La récolte des disponibilités n'a pas encore commencé</span>"
    message =
      'Elle a lieu du 10 au 20 de chaque mois.<br /><br />' +
      '<strong>Veuillez attendre le 10 pour pouvoir indiquer vos disponibilités.<br />Merci !</strong>'
  else
    title = '<img src="/late.png" /><span>La récolte des disponibilités est passée !</span>'
    message =
      'Elle a lieu du 10 au 20 de chaque mois<br /><br />' +
      '<strong>' +
        'Si vos disponibilités ont évolué, contactez Noémie !<br />' +
        '<div class="contact-info"><i class="fa fa-envelope" /> <a href="mailto:noemie.maldorane@gmail.com">noemie.maldorane@gmail.com</a></div>' +
        '<div class="contact-info"><i class="fa fa-phone"    /> 06 68 59 15 46</div>' +
      '</strong>'
  $('#user-presence-calendar').append(
    '<div class="availabilities-disabled-message">' +
      "<h2>#{title}</h2>" +
      message
    '</div>'
  )

addMessages = (planning) ->
  $('.day-message').each ->
    React.render(<DayMessage planning={planning} date={$(@).data('date')}/>, @)

Template.UserPresence.rendered = ->
  planning = @data.planning
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
                             <div class="day-message" data-date="<%= moment(days[d].date).format("DD/MM/YYYY") %>"></div>
                             <% _.each(eventsForDayByGroup, function(eventsGroup) { %>
                               <% var requiredEvent = eventsGroup.find({required: true}) %>
                               <div class="group">
                                 <div class="name"><%= eventsGroup[0].name %></div>
                                 <% _.each(eventsGroup, function(event) { %>
                                   <% var optionalEventShouldBeDisabled = requiredEvent && event != requiredEvent && !requiredEvent.present %>
                                   <div class="checkbox <%= optionalEventShouldBeDisabled && "disabled" || "" %>" data-event-id="<%= event._id %>">
                                     <div class="detail"><%= event.detail %></div>
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
    startWithMonth: @data.planning.events.first().date
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
    events: buildEvents(planning.events)
    showAdjacentMonths: true
    forceSixRows: null
  Plannings.find().observeChanges
    changed: (id) ->
      planning = Plannings.findOne(id)
      user_presence_calendar.setEvents buildEvents(planning.events)
      addMessages(planning)
  unless availabilitiesActive()
    addOverlay()
    addAvailabilitiesDisabledMessage()
  addMessages(planning)

Template.UserPresence.events
  'click #user-presence-calendar .checkbox:not(.disabled)': (event) ->
    successPopup()
    eventId = $(event.currentTarget).data('event-id')
    Meteor.call 'togglePresence', @planning._id, eventId, Meteor.userId()
