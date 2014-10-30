#= require active_admin/base
$(->

  if $('.admin_places').length
    resource = 'places'
  else if $('.admin_cities').length
    resource = 'cities'
  else if $('.admin_countries').length
    resource = 'countries'
  else if $('.admin_categories').length
    resource = 'categories'

  $('input[class=translate]').keypress( (e)->
    if e.which == 13
      $.ajax(
        method : 'PUT'
        url : "/admin/#{resource}/#{e.target.name}/translate"
        data :
          translate : e.target.value
        success : (place)->
          $(e.target).parent().prev().text(place.rus_name)
          $(e.target).parents('tr').find('.col-translate .status_tag').removeClass('no').addClass('yes').text('YES')
          $(e.target).parents('tr').next().find('.translate').focus()
        error : ->
          console.log 'fault'
      )
      e.preventDefault
      return false
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

  message = $('<div class="alert"></div>')
  $('body').append(message)
  message.hide()

  setInterval( ->
    $.ajax(
        url: '/admin/status'
        type: "GET"
        success: (status) ->
          if status.status
            message.show()
            message.text(status.status)
          else
            message.text('')
            message.hide()
        error: ->
    )
  ,5000);
  )