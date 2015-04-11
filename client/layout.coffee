Template.Layout.helpers
  containerType: ->
    fluid = Session.get('fluid') || false
    type = "container"
    type += "-fluid" if fluid
    type

Template.Nav.events
  "click .toggleFluid": ->
    fluid = Session.get('fluid') || false
    Session.set('fluid', !fluid)
Template.Nav.helpers
  isFluid: ->
    Session.get('fluid')
