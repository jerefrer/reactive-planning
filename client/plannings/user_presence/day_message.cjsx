@DayMessage = React.createClass
  render: ->
    <MessageButton planning={@props.planning} date={@props.date} />

MessageButton = React.createClass
  message: ->
    if messagesForDay = @props.planning.messagesForAvailabilityDays[@props.date]
      if messageForDay = messagesForDay.find(userId: Meteor.userId())
        messageForDay.message
  messagePresent: ->
    !!@message()
  render: ->
    className = React.addons.classSet
      on: @messagePresent()
      off: !@messagePresent()
    <ReactBootstrap.ModalTrigger modal={<MessageModal planning={@props.planning} date={@props.date} message={@message()} />}>
      <div className={className}>
        <i className='on  fa fa-comment' title='Ajouter un message' />
        <i className='off fa fa-comment-o' title='Modifier mon message' />
      </div>
    </ReactBootstrap.ModalTrigger>


MessageModal = React.createClass
  dayName: ->
    momentDate = moment(@props.date, 'DD/MM/YYYY')
    momentDate.format('dddd DD ').capitalize() +
    momentDate.format('MMMM').capitalize()
  componentDidMount: ->
    @refs.message.getDOMNode().value = @props.message if @props.message
    @refs.message.getDOMNode().focus()
  updateMessage: (e) ->
    e.preventDefault()
    message = @refs.message.getDOMNode().value.trim()
    if message == ''
      @removeMessage()
    else
      Meteor.call('setMessageForAvailabilityDay', @props.planning._id, @props.date, Meteor.userId(), message)
      successPopup("Message enregistré.")
      @props.onRequestHide()
  removeMessageOrCancelButton: ->
    if @props.message && @props.message != ''
      <a className="btn btn-danger" onClick={@removeMessage}>Supprimer mon message</a>
    else
      <a className="btn btn-default" onClick={@props.onRequestHide}>Annuler</a>
  removeMessage: ->
    Meteor.call('removeMessageForAvailabilityDay', @props.planning._id, @props.date, Meteor.userId())
    successPopup("Message supprimé.")
    @props.onRequestHide()
  render: ->
    <ReactBootstrap.Modal {...@props} bsStyle='primary' bsSize='large' animation>
      <form onSubmit={@updateMessage} className="day-message-form">
        <h2>
          <i className="fa fa-comment" />
          {@dayName()}
        </h2>
        <div className="subtitle">Vous pouvez entrer ici un message si vous avez des précisions à apporter concernant votre présence le {@dayName()}.</div>
        <textarea ref="message" className="form-control"></textarea>
        {@removeMessageOrCancelButton()}
        <button className="btn btn-primary">Valider</button>
        <div className="clearfix"></div>
      </form>
    </ReactBootstrap.Modal>
