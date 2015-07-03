@successPopup = (message, timeout=1500) ->
  toastr.success(message, 'Modification enregistrée', positionClass: 'toast-bottom-right', timeOut: timeout)
