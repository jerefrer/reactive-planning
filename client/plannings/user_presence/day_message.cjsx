@DayMessage = React.createClass
  # mixins: [ ReactMeteor.Mixin ]
  # startMeteorSubscriptions: ->
  #   Meteor.subscribe 'users'
  #   Meteor.subscribe 'plannings'
  # getMeteorState: ->
  #   state =
  #     duties: []
  #     people: Meteor.users.find().fetch()
  #   if @props.planning
  #     state.duties = @props.planning.duties
  #   state
  render: ->
    <MessageButton planning={@props.planning} date={@props.date} />

MessageButton = React.createClass
  messagePresent: ->
    if messagesForDay = @props.planning.messagesForAvailabilityDays[@props.date]
      !!messagesForDay.find(userId: Meteor.userId())
  render: ->
    className = React.addons.classSet
      fa: true
      'fa-comment': @messagePresent()
      'fa-comment-o': !@messagePresent()
    <ReactBootstrap.ModalTrigger modal={<MessageModal planning={@props.planning} date={@props.date} />}>
      <i className={className} />
    </ReactBootstrap.ModalTrigger>


MessageModal = React.createClass
  updateMessage: (e) ->
    e.preventDefault()
    message = @refs.message.getDOMNode().value.trim()
    if message != ''
      Meteor.call('setMessageForAvailabilityDay', @props.planning._id, @props.date, Meteor.userId(), message)
      successPopup("Message enregistré.")
  render: ->
    <ReactBootstrap.Modal {...@props} bsStyle='primary' bsSize='large' animation>
      <form onSubmit={@updateMessage}>
        <textarea ref="message"></textarea>
        <button className="btn btn-primary pull-left">Valider</button>
      </form>
    </ReactBootstrap.Modal>
