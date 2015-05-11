@SendPasswordEmailsButton = React.createClass
  mixins: [ ReactMeteor.Mixin ]
  startMeteorSubscriptions: ->
    Meteor.subscribe 'users'
  getInitialState: ->
    sending: false
    showingSuccess: false
  getMeteorState: ->
    emailsToSend: !!usersWithoutPassword().length
  sendNotifications: (e) ->
    e.preventDefault()
    if @state.emailsToSend
      @setState sending: true
      Meteor.call 'sendPasswordEmails', =>
        @setState
          sending: false
          showingSuccess: true
        setTimeout (=> @setState showingSuccess: false), 5000
  render: ->
    return null unless @state.emailsToSend or @state.sending or @state.showingSuccess
    className = "send-emails-button send-password-emails-button btn "
    inner = undefined
    style = undefined
    if @state.showingSuccess
      inner = <i className="fa fa-check-circle-o" />
      className += 'btn-success with-icon'
      style = width: '50px'
    else if @state.sending
      inner = <i className="fa fa-spinner fa-spin" />
      className += 'btn-primary with-icon'
      style = width: '50px'
    else
      inner = <span><i className="fa fa-envelope" />Envoyer les mots de passe</span>
      className += 'btn-primary'
    <button className={className} style={style} onClick={@sendNotifications}>{inner}</button>
