sendEmail = (planning, user, filePath) ->
  options = _.extend {},
  heading: "Bonjour #{user.profile.firstname}"
  headingSmall: "<br />Ci-joint le planning de #{planning.name}"
  html = PrettyEmail.render 'basic', options
  mailgun().send
    to: user.emails[0].address
    from: 'Planning 24 <no-reply@planning-24.meteor.com>'
    subject: "Le planning de #{planning.name}"
    html: html
    attachment: filePath

Meteor.methods
  sendExcelExport: (slug) ->
    excel = new Excel('xlsx')
    workbook = excel.createWorkbook()
    worksheet = excel.createWorksheet()
    planning = Plannings.findOne(slug: slug)

    # Columns titles & width
    widths = []
    planning.tasks.each (task, column) ->
      worksheet.writeToCell 0, column + 1, task.name
      widths.push { wch: 15 }
    worksheet.setColumnProperties widths

    # Rows for each days
    planning.days.each (day, row) ->
      worksheet.writeToCell row + 1, 0, day.name
      planning.tasks.each (task, column) ->
        if duties = planning.duties["#{day._id},#{task._id}"]
          peopleNames = duties.map (duty) ->
            displayName(Meteor.users.findOne(_id: duty._id))
          worksheet.writeToCell row + 1, column + 1, peopleNames.join("\n")

    # Write file
    workbook.addSheet "Planning de #{planning.name}", worksheet
    mkdirp 'tmp', Meteor.bindEnvironment (err) ->
      if err
        console.log 'Error creating tmp dir', err
        futureResponse.throw err
      else
        filePath = './tmp/' + planning.slug + '.xlsx'
        workbook.writeToFile filePath
        user = Meteor.users.findOne('emails.address': 'frere.jeremy@gmail.com')
        sendEmail planning, user, filePath
