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
            <input type="text" id="start_hour"/>
            :
            <input type="text" id="start_min"/>
            <select id="start">
              <option value="AM">AM</option>
              <option value="PM">PM</option>
            </select>
            <br/>
            To&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="text" id="end_hour"/>
            :
            <input type="text" id="end_min"/>
            <select id="end">
              <option value="AM">AM</option>
              <option value="PM">PM</option>
            </select>
          </div>' +
          (unless @opts.persistent_time
            '<button class="btn btn-success">Schedule</button>'
           else
             '') +
        '</div>
      '

      @daytimes = []

      @init()

    init: ->

      persistent_time = @opts.persistent_time
      daytimes = => @daytimes

      push_time = (day) =>
        start_hour = parseInt( $('#time_container #start_hour').val() )
        start_hour += 12 if $('#time_container select#start').val() == 'PM'
        start_time = start_hour + ':' + $('#time_container #start_min').val()
        end_hour = parseInt( $('#time_container #end_hour').val() )
        end_hour += 12 if $('#time_container select#end').val() == 'PM'
        end_time = end_hour + ':' + $('#time_container #end_min').val()

        @daytimes = _.filter(@daytimes, (obj) -> obj.day != day)
        @daytimes.push {day: day, start_time: start_time, end_time: end_time}

      remove_time = (day) => @daytimes = _.filter(@daytimes, (obj) -> obj.day != day)

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
            html =
              (if _.find(@daytimes, (obj) -> obj.day == day)
                '<td selected="selected" style="background-color:rgba(204,255,153,0.65)" '
              else
                '<td ') +
              (if row == 1 && i < first_day || current_day >= month_days
                '<td class="day">'
              else
                '<td class="day day' + i + '">' + ++current_day) + '</td>'
            $('#calendar tbody').append(html)
          $('#calendar tbody').append('</tr>')

        $('#calendar td').hover(
          -> $(this).css('background-color', 'rgba(204,255,153,0.65)'),
          -> $(this).css('background-color', 'transparent') if $(this).attr('selected') != 'selected'
        )
        $('#calendar th.day').hover(
          (->
            $(this).css('background-color', 'rgba(204,204,255,0.5)')
            $( '.day' + $(this).attr('day') ).css('background-color', 'rgba(204,255,153,0.65)')
          ),
          (->
            $(this).css('background-color', 'transparent')
            $( '.day' + $(this).attr('day') ).each ->
              $(this).css('background-color', 'transparent') if $(this).attr('selected') != 'selected'
          )
        )

        $('#calendar tbody td.day').click ->
          daytiems = daytimes()
          day = $(this).text() + '-' + month + '-' + year
          if persistent_time
            if $(this).attr('selected') == 'selected'
              $(this).removeAttr('selected')
              $(this).css('background-color', 'transparent')
              remove_time day
            else
              $(this).attr('selected', 'true')
              $(this).css('background-color', 'rgba(204,255,153,0.65)')
              push_time day
          else
            if $(this).attr('selected') == 'selected'
              obj = _.find(daytiems, (obj) -> obj.day == day)
              $('#time_container #start_min').val(obj.start_time.replace(/\d*:/, ''))
              $('#time_container #start_hour').val(obj.start_time.replace(/:\d*/, ''))
              $('#time_container #end_min').val(obj.end_time.replace(/\d*:/, ''))
              $('#time_container #end_hour').val(obj.end_time.replace(/:\d*/, ''))
            else
              $(this).attr('selected', 'true')
            $('#time_container').fadeIn()

            $('#time_container .btn').click =>
              $('#time_container .btn').unbind()
              $('#time_container').fadeOut()
              push_time day

      ## end function helpers ##

      $('body').prepend(@calendar_skeleton).prepend(@time_skeleton)
      gen_cal(@opts.month, @opts.year)

      $('#cal_submit').click =>
        $('#calendar').fadeOut() if @opts.popup
        @opts.submit @daytimes

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

      if @opts.popup
        $(@element).click =>
          $('#calendar').css('top', $(@element).offset().top + $(@element).height() + 5)
          $('#calendar').css('left', $(@element).offset().left)
          $('#calendar').fadeIn()
      else
        $('#calendar').appendTo( $(@element) )
        $('#calendar').css('display', 'inline-block').css('position', 'relative')
        $('#time_container').css('top', $('#calendar').offset().top)
        $('#time_container').css('left', $('#calendar').offset().left + $('#calendar').width() + 5)
        $('#time_container').fadeIn(0) if @opts.persistent_time

  $.fn[pluginName] = (options) ->
    @each ->
      if !$.data(this, "plugin_#{pluginName}")
        $.data(@, "plugin_#{pluginName}", new Plugin(@, options))
)(jQuery, window, document)
