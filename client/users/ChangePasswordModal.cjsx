@ChangePasswordModalTrigger = React.createClass
  render: ->
    <ReactBootstrap.ModalTrigger modal={<ChangePasswordModal user={@props.user} />}>
      <a className="btn btn-primary">Changer le mot de passe</a>
    </ReactBootstrap.ModalTrigger>

ChangePasswordModal = React.createClass
  changePassword: (e) ->
    e.preventDefault()
    Meteor.call 'updatePassword', @props.user._id, @refs.password.getDOMNode().value.trim()
    successPopup("Mot de passe mis-à-jour.")
    @props.onRequestHide()
  render: ->
    <ReactBootstrap.Modal {...@props} bsStyle='primary' title="Changer le mot de passe de #{@props.user.username}" animation>
      <div className='modal-body'>
        <input ref="password" className="form-control" placeholder="Entrez le nouveau mot de passe" />
      </div>
      <div className='modal-footer'>
        <button className="btn btn-primary" onClick={@changePassword}>Valider</button>
        <button className="btn btn-default" onClick={@props.onRequestHide}>Annuler</button>
      </div>
    </ReactBootstrap.Modal>

