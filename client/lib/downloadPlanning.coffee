@downloadPlanning = (planning) ->
  Meteor.call 'downloadExcelFile', planning, (err, fileUrl) ->
    link = document.createElement("a")
    link.download = "Planning de #{planning.name}.xlsx"
    link.href = fileUrl
    link.click()
