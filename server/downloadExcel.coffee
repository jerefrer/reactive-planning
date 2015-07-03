Meteor.startup ->
  temporaryFiles.allow
    insert: (userId, file) -> true
    remove: (userId, file) -> true
    read: (userId, file) -> true
    write: (userId, file, fields) -> true

Meteor.methods
  downloadExcelFile : (planning) ->
    Future = Npm.require('fibers/future')
    futureResponse = new Future()

    workbook = buildExcelForPlanning(planning)

    mkdirp 'tmp', Meteor.bindEnvironment (err) ->
      if err
        console.log 'Error creating tmp dir', err
      else
        uuid = Meteor.uuid()
        filePath = './tmp/' + uuid
        workbook.writeToFile filePath
        temporaryFiles.importFile filePath, {
          filename : uuid,
          contentType: 'application/octet-stream'
        }, (err, file) ->
          if (err)
            futureResponse.throw(err)
          else
            futureResponse.return('/gridfs/temporaryFiles/' + file._id)
    futureResponse.wait()
