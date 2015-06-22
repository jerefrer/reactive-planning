pad2 = (number) ->
  ("0" + number).slice(-2)

@sortPlannings = (plannings) ->
  _.sortBy plannings, (planning) ->
    planning.year.toString() + pad2(planning.month)
