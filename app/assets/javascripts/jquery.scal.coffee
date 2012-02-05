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
                <th colspan="7">
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
          </div>
          <button class="btn btn-success">Schedule</button>
        </div>
      '

      @daytimes = []

      @init()

    init: ->
      daytimes = => @daytimes
      month = => @opts.month + 1
      year = => @opts.year

      first_day = new Date(@opts.year, @opts.month, 1).getDay()
      month_name = @months[@opts.month]
      month_days = @month_days[@opts.month]
      month_length =
        if @opts.month == 1 && (@opts.year % 4 == 0 && @opts.year % 100 != 0 || @opts.year % 400 == 0)
          29
        else
          month_days
      num_rows =
        if month_days + first_day >= 35
          6
        else if first_day == 0 && month_days == 28
          4
        else
          5

      $('body').prepend(@calendar_skeleton).prepend(@time_skeleton)
      $('#calendar #month_header th').text(month_name + ' ' + @opts.year)

      current_day = 0
      for row in [1..num_rows]
        $('#calendar tbody').append('<tr class="week">')
        for day, i in @days
          html =
            if row == 1 && i < first_day || current_day > month_days
              '<td class="day">'
            else
              '<td class="day day' + i + '">' + ++current_day
          html += '</td>'
          $('#calendar tbody').append(html)
        $('#calendar tbody').append('</tr>')

      $('#calendar td').hover(
        -> $(this).css('background-color', 'rgba(204,255,153,0.65)'),
        -> $(this).css('background-color', 'transparent')
      )
      $('#calendar th.day').hover(
        (->
          $(this).css('background-color', 'rgba(204,204,255,0.5)')
          $( '.day' + $(this).attr('day') ).css('background-color', 'rgba(204,255,153,0.65)')
        ),
        (->
          $(this).css('background-color', 'transparent')
          $( '.day' + $(this).attr('day') ).css('background-color', 'transparent')
        )
      )

      $('#calendar td.day').click ->
        $('#time_container').css('top', $('#calendar').offset().top)
        $('#time_container').css('left', $('#calendar').offset().left + $('#calendar').width() + 5)
        $('#time_container').fadeIn()

        $('#time_container .btn').click =>
          $('#time_container .btn').unbind()
          $('#time_container').fadeOut()

          start_hour = parseInt( $('#time_container #start_hour').val() )
          start_hour += 12 if $('#time_container select#start').val() == 'PM'
          start_time = start_hour + ':' + $('#time_container #start_min').val()
          end_hour = parseInt( $('#time_container #start_hour').val() )
          end_hour += 12 if $('#time_container select#end').val() == 'PM'
          end_time = end_hour + ':' + $('#time_container #end_min').val()

          daytimes().push {day: month() + '-' + $(this).text() + '-' + year(), start_time: start_time, end_time: end_time}

      $('#cal_submit').click =>
        $('#calendar').fadeOut()
        @opts.submit @daytimes

      $(@element).click =>
        $('#calendar').css('top', $(@element).offset().top + $(@element).height() + 5)
        $('#calendar').css('left', $(@element).offset().left)
        $('#calendar').fadeIn()

  $.fn[pluginName] = (options) ->
    @each ->
      if !$.data(this, "plugin_#{pluginName}")
        $.data(@, "plugin_#{pluginName}", new Plugin(@, options))
)(jQuery, window, document)
