@SendAvailabilityReminderButton = React.createClass
  getInitialState: ->
    sending: false
    showingSuccess: false
  sendAvailabilityReminder: (e) ->
    e.preventDefault()
    if confirm("Vous êtes sur le point d'envoyer une relance à tous les bénévoles qui n'ont pas encore donné leurs disponibilités.\n\nÊtes-vous sûr ?")
      @setState sending: true
      Meteor.call 'sendAvailabilityReminder', @props.planning._id, (error, data) =>
        @setState
          sending: false
          showingSuccess: true
        setTimeout (=> @setState showingSuccess: false), 5000
  render: ->
    className = "send-emails-button send-availability-emails-button btn "
    if @state.showingSuccess
      inner = <i className="fa fa-check-circle-o" />
      className += 'btn-success with-icon'
      style = width: '50px'
    else if @state.sending
      inner = <i className="fa fa-spinner fa-spin" />
      className += 'btn-primary with-icon'
      style = width: '50px'
    else
      inner = <span><i className="fa fa-envelope" />Envoyer un e-mail de relance</span>
      className += 'btn-primary'
    <button className={className} style={style} onClick={@sendAvailabilityReminder}>{inner}</button>
