@excelExportPlanning = (planning, filePath) ->
  excel = new Excel('xlsx')
  workbook = excel.createWorkbook()
  worksheet = excel.createWorksheet()

  # Columns titles & width
  widths = [{ wch: 30 }]
  planning.tasks.each (task, column) ->
    worksheet.writeToCell 0, column + 1, task.name
    widths.push { wch: 30 }
  worksheet.setColumnProperties widths

  # Rows for each days
  planning.days.each (day, row) ->
    worksheet.writeToCell row + 1, 0, day.name
    planning.tasks.each (task, column) ->
      if duties = planning.duties["#{day._id},#{task._id}"]
        peopleNames = duties.map (duty) ->
          displayName(Meteor.users.findOne(_id: duty._id))
        worksheet.writeToCell row + 1, column + 1, peopleNames.join(', ')

  # Write file
  workbook.addSheet "Planning de #{planning.name}", worksheet
  mkdirp 'tmp', Meteor.bindEnvironment (err) ->
    if err
      console.log 'Error creating tmp dir', err
    else
      workbook.writeToFile filePath
