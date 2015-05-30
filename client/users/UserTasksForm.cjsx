Tasks = new Meteor.Collection('tasks')
DragDropMixin = ReactDND.DragDropMixin
ItemTypes = TASK: 'task'

@UserTasksForm = React.createClass
  mixins: [ ReactMeteor.Mixin ]
  startMeteorSubscriptions: ->
    Meteor.subscribe 'users'
    Meteor.subscribe 'tasks'
  getMeteorState: ->
    user: Meteor.users.findOne(@props.userId)
    tasks: Tasks.find().fetch()
  render: ->
    <ReactBootstrap.ModalTrigger modal={<UserTasksModal user={@state.user} tasks={@state.tasks} />}>
      <a className="btn btn-primary">Modifier ses rôles</a>
    </ReactBootstrap.ModalTrigger>

UserTasksModal = React.createClass
  render: ->
    <ReactBootstrap.Modal {...@props} bsStyle='primary' title="Rôles de #{@props.user.username}" animation>
      <div className='modal-body'>
        <div className="row same-height-columns">
          <TaskList tasks={@props.tasks} user={@props.user} />
          <div className="divider"></div>
          <PreferedOrBannedTaskList user={@props.user} tasks={@props.user.preferedTasks} preferedOrBanned='Prefered' />
          <PreferedOrBannedTaskList user={@props.user} tasks={@props.user.bannedTasks}   preferedOrBanned='Banned' />
        </div>
      </div>
      <div className='modal-footer'>
        <ReactBootstrap.Button onClick={@props.onRequestHide}>Fermer</ReactBootstrap.Button>
      </div>
    </ReactBootstrap.Modal>

TaskList = React.createClass
  getInitialState: ->
    tasks: @props.tasks
  getRemainingTasks: (tasks) ->
    tasks.findAll (task) =>
      preferedTasksIds = (@props.user.preferedTasks || []).map('_id')
      bannedTasksIds   = (@props.user.bannedTasks || []).map('_id')
      preferedTasksIds.concat(bannedTasksIds).indexOf(task._id) < 0
  render: ->
    tasksList = @getRemainingTasks(@state.tasks).map (task) -> <Task task={task} />
    <div className="tasks-list col-md-4">
      <h3 className="text-success">Tâches</h3>
      <ul className="list-unstyled">{tasksList}</ul>
    </div>

TaskFilters = React.createClass
  handleChange: ->
    @props.onChange @refs.name.getDOMNode().value.trim()
  render: ->
    <div className="form-group form-inline">
      <label className="control-label">Nom</label>
      <input type="text" ref="name" onChange={@handleChange} className="form-control" />
    </div>

PreferedOrBannedTaskList = React.createClass
  handleTaskDrop: (task) ->
    cell = task.scheduleCell
    Meteor.call "addUser#{@props.preferedOrBanned}Task", @props.user._id, task._id
  removeTask: (task) ->
    Meteor.call "removeUser#{@props.preferedOrBanned}Task", @props.user._id, task._id
  mixins: [ DragDropMixin ]
  statics: configureDragDrop: (register) ->
    register ItemTypes.TASK, dropTarget:
      acceptDrop: (component, task) ->
        component.handleTaskDrop task
  render: ->
    tasks = @props.tasks
    tasksList = undefined
    if tasks
      tasksList = tasks.map (taskId) =>
        task = Tasks.findOne(taskId)
        <Task task={task} onThrowAway={@removeTask} />
    dropState = @getDropState(ItemTypes.TASK)
    className = React.addons.classSet
      "preferred-tasks": @props.preferedOrBanned == 'Prefered'
      "banned-tasks": @props.preferedOrBanned == 'Banned'
      "col-md-4": true
      "drop-target": dropState.isDragging
      "drop-hover": dropState.isHovering
    <div {...@dropTargetFor(ItemTypes.TASK)} className={className}>
      <h3>{@props.preferedOrBanned == 'Prefered' && 'Souvent' || 'Jamais'}</h3>
      {tasksList}
    </div>

Task = React.createClass
  mixins: [ DragDropMixin ]
  statics: configureDragDrop: (register) ->
    register ItemTypes.TASK, dragSource:
      beginDrag: (component) ->
        { item: component.props.task }
      endDrag: (component, effect) ->
        if !effect
          if component.props.onThrowAway
            component.props.onThrowAway component.props.task
  render: ->
    <div className="task"
        {...@dragSourceFor(ItemTypes.TASK)}>
      {@props.task.name}
    </div>
