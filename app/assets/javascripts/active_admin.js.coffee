#= require active_admin/base
$(->
  $('input[class=translate]').keypress( (e)->
    if e.which == 13
      e.preventDefault
      window.eee = e
      $.ajax(
        method : 'PUT'
        url : '/admin/translate'
        data :
          id : e.target.name
          translate : e.target.value
        success : (place)->
          window.sss = place
          $(eee.target).parent().prev().text(place.name)
          $(eee.target).parents('tr').next().find('.translate').focus()
        fault : ->
          console.log 'fault'
      )
  )

  $('#countries_selector').change((e) ->
    $.ajax(
      method : 'GET'
      url : '/admin/cities/by/country'
      dataType : 'html'
      data :
        id : e.target.value
      success : (cities) ->
        $('#cities_selector').html(cities)
    )
  )

  $('#cities_submit').submit((e) ->
    console.log $('#cities_selector').value
    return false unless $('#cities_selector').val()
  )

)