#  Project: Scal
#  Description: calendar thing
#  Author: Chris Bolton
#  License: WTFPL

# the semi-colon before function invocation is a safety net against concatenated
# scripts and/or other plugins which may not be closed properly.
``
(($, window, document) ->
  pluginName = 'scal'
  defaults =
    month: new Date().getMonth(),
    year: new Date().getFullYear(),
    padding: '10',
    popup: true,
    persistent_time: false,
    submit: ->
    preset_data: []

  class Plugin
    constructor: (@element, options) ->
      @opts = $.extend {}, defaults, options

      @_defaults = defaults
      @_name = pluginName

      @days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
      @months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
      @month_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

      @calendar_skeleton = '
        <div id="calendar">
          <table border="1" cellpadding="' + @opts.padding + '">
            <thead>
              <tr id="month_header">
                <td direction="prev"><</td>
                <th colspan="5">
                <td direction="next">></td>
                </th>
              </tr>
              <tr id="days_header">' +
                ('<th class="day" day="' + i + '">' + day + '</th>' for day, i in @days).join(' ') +
              '</tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
              <tr id="cal_submit_footer">
                <th colspan="7">
                  <button id="cal_submit" class="btn btn-success">Submit</button>
                </th>
              </tr>
            </tfoot>
          </table>
        </div>
      '

      @time_skeleton = '
        <div id="time_container">
          <div id="time_picker">
            From
            <input type="text" class="hour" id="start_hour"/>
            :
            <input type="text" class="minute" id="start_min"/>
            <select id="start">
              <option value="AM">AM</option>
              <option value="PM">PM</option>
            </select>
            <br/>
            To&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="text" class="hour" id="end_hour"/>
            :
            <input type="text" class="minute" id="end_min"/>
            <select id="end">
              <option value="AM">AM</option>
              <option value="PM">PM</option>
            </select>
          </div>' +
          (unless @opts.persistent_time
            '<button class="btn btn-success">Schedule</button>'
           else
             '<dl style="width:150px"></dl>') +
        '</div>
      '

      @daytimes = []

      @init()

    init: ->

      persistent_time = @opts.persistent_time
      daytimes = => @daytimes

      push_time = (day) =>
        @daytimes = _.filter(@daytimes, (obj) -> obj.day != day)
        if persistent_time
          @daytimes.push {day: day}
        else
          start_hour = parseInt( $('#time_container #start_hour').val() )
          start_hour += 12 if $('#time_container select#start').val() == 'PM'
          start_time = start_hour + ':' + $('#time_container #start_min').val()
          end_hour = parseInt( $('#time_container #end_hour').val() )
          end_hour += 12 if $('#time_container select#end').val() == 'PM'
          end_time = end_hour + ':' + $('#time_container #end_min').val()
          @daytimes.push {day: day, start_time: start_time, end_time: end_time}

      remove_time = (day) => @daytimes = _.filter(@daytimes, (obj) -> obj.day != day)

      push = (hash) => @daytimes.push hash

      push_time(obj.day) for day in @opts.preset_data

      toggle = (day, element, _switch = 'toggle') =>
        daytiems = daytimes()
        month = $('#calendar thead th').attr('month')
        year = $('#calendar thead th').attr('year')
        month_name = @months[month]
        element.removeClass('deselecting')
        if persistent_time
          selector = '#time_container div#month' + month
          if element.attr('selected') == 'selected' && _switch != 'on' || _switch == 'off'
            element.removeAttr('selected').removeClass('selected')
            $('#selected-day' + element.text()).remove()
            $(selector).remove() unless $(selector + ' dd').html()
            remove_time day
          else unless _.find(daytiems, (obj) -> obj.day == day)
            push_time day
            element.attr('selected', 'true').addClass('selected')
            $('#time_container dl').append('<div id="month' + month + '"><dt>' + month_name + ' ' + year + '</dt><dd></dd></div>') unless $(selector)[0]
            $('#month' + month + ' dd').append('<span>' + element.text() + ', </span>')
            array = []
            $('#month' + month + ' dd span').each ->
              array.push parseInt($(this).text())
            array.sort((n1,n2) -> n1 - n2)
            $('#month' + month + ' dd').html('')
            for n in array
              $('#month' + month + ' dd').append('<span id="selected-day' + n + '">' + n + ', </span>')
        else
          if element.attr('selected') == 'selected' && _switch != 'on' || _switch == 'off'
            obj = _.find(daytiems, (obj) -> obj.day == day)
            $('#time_container #start_min').val(obj.start_time.replace(/\d*:/, ''))
            $('#time_container #start_hour').val(obj.start_time.replace(/:\d*/, ''))
            $('#time_container #end_min').val(obj.end_time.replace(/\d*:/, ''))
            $('#time_container #end_hour').val(obj.end_time.replace(/:\d*/, ''))
          else
            element.attr('selected', 'true').addClass('selected')
          $('#time_container').fadeIn()

          $('#time_container .btn').click =>
            $('#time_container .btn').unbind()
            $('#time_container').fadeOut()
            push_time day

      gen_cal = (month, year) =>
        $('#calendar thead th').attr('month', month)
        $('#calendar thead th').attr('year', year)
        first_day = new Date(year, month, 1).getDay()
        month_name = @months[month]
        month_days = @month_days[month]
        month_days =
          if month == 1 && (year % 4 == 0 && year % 100 != 0 || year % 400 == 0)
            29
          else
            month_days
        num_rows =
          if month_days + first_day > 35
            6
          else if first_day == 0 && month_days == 28
            4
          else
            5

        $('#calendar tbody').html('')
        $('#calendar #month_header th').text(month_name + ' ' + year)

        current_day = 0
        for row in [1..num_rows]
          $('#calendar tbody').append('<tr class="week">')
          for day, i in @days
            day = (current_day + 1) + '-' + month + '-' + year
            html = '<td ' +
              (if row == 1 && i < first_day || current_day >= month_days
                'class="day">'
              else
                ++current_day
                'id="day' + current_day + '" class="day day' + i + '">' + current_day) + '</td>'
            $('#calendar tbody').append(html)
          $('#calendar tbody').append('</tr>')

        for daytime in @daytimes
          this_day = daytime.day.split('-')[0]
          this_month = daytime.day.split('-')[1]
          this_year = daytime.day.split('-')[2]
          if parseInt(this_month) == month + 1 && parseInt(this_year) == year
            element = $('#day' + this_day).attr('selected', 'true').addClass('selected')

        $('#calendar tbody td.day').hover(
          (->
            if $(this).text() != ''
              if $(this).attr('selected')
                $(this).removeClass('selected').removeClass('hover').addClass('deselecting')
              else
                $(this).addClass('hover')
          ),
          (->
            if $(this).text() != ''
              if $(this).attr('selected')
                $(this).addClass('selected')
              else
                $(this).removeClass('hover')
          )
        )
        $('#calendar thead th.day').hover(
          (->
            all_selected = _.all($('#calendar tbody td.day' + $(this).attr('day')), (t) -> $(t).attr('selected'))
            $(this).addClass('hover')
            if all_selected
              $('.day' + $(this).attr('day')).each ->
                $(this).removeClass('hover')
                $(this).removeClass('selected')
                $(this).addClass('deselecting')
            else
              $('.day' + $(this).attr('day')).each -> $(this).addClass('hover')
          ),
          (->
            all_selected = _.all($('#calendar tbody td.day' + $(this).attr('day')), (t) -> $(t).attr('selected'))
            $(this).removeClass('hover')
            $('.day' + $(this).attr('day')).each ->
              $(this).removeClass('hover')
              $(this).addClass('selected') if all_selected
          )
        )

        $('#calendar tbody td.day').click ->
          if $(this).text() != ''
            day = $(this).text() + '-' + (month + 1) + '-' + year
            toggle(day, $(this))

      ## end function helpers ##

      $('body').prepend(@calendar_skeleton).prepend(@time_skeleton)
      gen_cal(@opts.month, @opts.year)

      $('#cal_submit').click =>
        $('#calendar').fadeOut() if @opts.popup
        if persistent_time
          $('#calendar tbody td.day[selected]').each ->
            month = parseInt($('#calendar thead th').attr('month'))
            year = $('#calendar thead th').attr('year')
            day = $(this).text() + '-' + (month + 1) + '-' + year

            start_hour = parseInt( $('#time_container #start_hour').val() )
            start_hour += 12 if $('#time_container select#start').val() == 'PM'
            start_time = start_hour + ':' + $('#time_container #start_min').val()
            end_hour = parseInt( $('#time_container #end_hour').val() )
            end_hour += 12 if $('#time_container select#end').val() == 'PM'
            end_time = end_hour + ':' + $('#time_container #end_min').val()

            push {day: day, start_time: start_time, end_time: end_time}
        @opts.submit @daytimes

      $('#calendar thead th.day').click ->
        all_selected = _.all($('#calendar tbody td.day' + $(this).attr('day')), (t) -> $(t).attr('selected'))
        $('#calendar tbody td.day' + $(this).attr('day')).each ->
          month = parseInt($('#calendar thead th').attr('month'))
          year = $('#calendar thead th').attr('year')
          day = $(this).text() + '-' + (month + 1) + '-' + year
          if all_selected
            toggle(day, $(this), 'off')
          else
            toggle(day, $(this), 'on')

      $('#calendar thead td').click ->
        month = parseInt($('#calendar thead th').attr('month')) + 1
        year = parseInt($('#calendar thead th').attr('year'))
        if $(this).attr('direction') == 'next'
          if month == 12
            gen_cal(0, year + 1)
          else
            gen_cal(month, year)
        else
          if month == 1
            gen_cal(11, year - 1)
          else
            gen_cal(month - 2, year)

      $('#time_container input.hour').keyup ->
        if parseInt($(this).val()) > 12 || isNaN(parseInt($(this).val()))
          $(this).attr('style', 'border: thin solid rgb(149, 59, 57)')
          $('#cal_submit').attr('disabled', 'true').addClass('disabled')
        else
          $(this).attr('style', '')
          $('#cal_submit').removeAttr('disabled').removeClass('disabled')

      $('#time_container input.minute').keyup ->
        if parseInt($(this).val()) > 59 || isNaN(parseInt($(this).val()))
          $(this).attr('style', 'border: thin solid rgb(149, 59, 57)')
          $('#cal_submit').attr('disabled', 'true').addClass('disabled')
        else
          $(this).attr('style', '')
          $('#cal_submit').removeAttr('disabled').removeClass('disabled')

      if @opts.popup
        $(@element).click =>
          $('#calendar').css('top', $(@element).offset().top + $(@element).height() + 5)
          $('#calendar').css('left', $(@element).offset().left)
          $('#calendar').fadeIn()
      else
        $('#calendar').appendTo( $(@element) )
        $('#time_container').appendTo( $(@element) )
        $('#calendar').css('display', 'inline-block').css('position', 'relative')
        $('#time_container').css('top', $('#calendar').offset().top)
        $('#time_container').css('left', $('#calendar').offset().left + $('#calendar').width() + 5)
        $('#time_container').fadeIn(0) if @opts.persistent_time

  $.fn[pluginName] = (options) ->
    @each ->
      if !$.data(this, "plugin_#{pluginName}")
        $.data(@, "plugin_#{pluginName}", new Plugin(@, options))
)(jQuery, window, document)
