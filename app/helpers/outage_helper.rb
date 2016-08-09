module OutageHelper
  INTERVAL_DURATION = 30.minutes
  ROW_INTERVAL_HEIGHT = 36

  def calendar(date, start_date, end_date, outages, &block)
    # puts date, start_date, end_date
    Calendar.new(self, date, start_date, end_date, outages, block).table
  end

  def day_style_calendar(date, start_date, end_date, outages, &block)
    DayCalendar.new(self, date, start_date, end_date, outages, block).render
  end

  def simple_outage_list(date, events)
    s = content_tag :p, date.day
    # puts s
    if events[date]
      s += content_tag :ul do
        events[date].map do |event|
          content_tag :li, class: "title" do
            # puts link_to(event.title, event)
            link_to event.title, event
          end
        end.join.html_safe
        # puts "Content Tags: " + debug.to_s
      end
      # puts s.html_safe
      # puts s
    end
    s
  end

  # I think this approach might be unnecessarily difficult. The "column for
  # time, columns for dates" approach will be simpler in many ways.
  # Overlaps will be simpler processing each outage as it comes up in the
  # sorted list.
  def day_schedule_outage_list(date, events)
    content_tag :div, class: "day-by-half-hour" do
      s = content_tag :p, date.day
      s += content_tag :ul do
        (0...((date.in_time_zone + 1.day) - date.in_time_zone)).step(INTERVAL_DURATION).map do |half_hour|
          # puts date + time.seconds
          content_tag :li do
            time = (date.in_time_zone + half_hour)
            a = []
            a << content_tag(:div, time.strftime("%H:%M"), class: "times")
            # a << day_schedule_outage(time, events[date])
            a << content_tag(:div,
                             day_schedule_outage(time, events[date]).join.html_safe,
                             class: "outages")
            a.join.html_safe
          end
        end.join.html_safe
      end
      # puts s
      s
    end
  end

  def day_schedule_outage(time, outages)
    return [] unless outages
    # puts "Outages: " + outages.length.to_s
    # puts "Date: " + time.to_date.to_s
    # puts "Start time: " + time.to_s
    outages.select do |event|
      # puts "#{event.start_datetime_utc.in_time_zone}, #{event.end_datetime_utc.in_time_zone}"
      # puts "#{event.start_datetime_on_date(time.to_date)}, #{event.end_datetime_on_date(time.to_date)}"
      # puts "#{time}, #{time + INTERVAL_DURATION}"
      # puts((time...time + INTERVAL_DURATION).cover?(event.start_datetime_on_date(time.to_date)) ? "true": "false")
      (time...time + INTERVAL_DURATION)
        .cover? event.start_datetime_on_date(time.to_date)
    end.map do |event|
      link_to(h(event.title), event, class: "outage-1 title", style: "height: #{event.duration(time.to_date) / (30 * 60) * ROW_INTERVAL_HEIGHT}px;")
    end
  end

  class Calendar < Struct.new(:view, :date, :start_date, :end_date, :outages, :callback)
    HEADER = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday).freeze
    START_DAY = :sunday

    delegate :content_tag, :link_to, to: :view

    def table
      content_tag :table, class: "calendar" do
        header + week_rows
      end
    end

    def header
      content_tag :tr do
        weeks[0]
          .map { |day| content_tag :th, day.strftime("%A") }.join.html_safe
        # HEADER.map { |day| content_tag :th, day }.join.html_safe
      end
    end

    def week_rows
      weeks.map do |week|
        content_tag :tr do
          week.map { |day| day_cell(day) }.join.html_safe
        end
      end.join.html_safe
    end

    def day_cell(day)
      content_tag :td, view.capture(day, &callback), class: day_classes(day)
    end

    def day_classes(day)
      classes = []
      classes << "today" if day == Date.today
      classes << "notmonth" if day.month != date.month
      classes.empty? ? nil : classes.join(" ")
    end

    def weeks
      # puts((first...last).to_a.in_groups_of(7).inspect)
      (start_date.to_date...end_date.to_date).to_a.in_groups_of(7, false)
    end
  end

  class DayCalendar < Calendar
    def render
      content_tag :div, class: "calendar clearfix" do
        a = []
        a << "calendar".html_safe
        a << content_tag(:div, class: "row-dates clearfix") do
          content_tag(:div, "space".html_safe, class: "col-times") +
            "row-dates".html_safe
        end
        a << outages_body
        a.join("\n").html_safe
      end
    end

    private

    def outages_body
      content_tag(:div, class: "outages-body clearfix") do
        a = []
        a << content_tag(:p, "outages-body".html_safe)
        a << content_tag(:div, class: "col-times") do
          render_times_column
        end
        a << content_tag(:div, class: "outages") do
          render_outages_column
        end
        a.join("\n").html_safe
      end
    end

    def render_times_column
      content_tag :ul do
        interval_iterator.map do |half_hour|
          # puts date + time.seconds
          content_tag :li, class: "time" do
            time = (date.in_time_zone + half_hour)
            time.strftime("%H:%M").html_safe
          end
        end.join("\n").html_safe
      end
    end

    def render_outages_column
      content_tag :div, class: "col-outages-1" do
        a = content_tag :ul do
          interval_iterator.map do
            # puts date + time.seconds
            content_tag :li
          end.join("\n").html_safe
        end

        a += outages[date].map do |o|
          link_to(o.title.html_safe,
                  o,
                  class: "outage title",
                  style: "height: #{duration_in_pixels(o)}px;" \
                         "top: #{start_time_in_pixels(o)}px;")
        end.join("\n").html_safe if outages[date]

        a
      end
    end

    def interval_iterator
      (0...((date.in_time_zone + 1.day) - date.in_time_zone)).step(INTERVAL_DURATION)
    end

    def duration_in_pixels(outage)
      seconds_to_pixels(outage.duration(date))
    end

    def start_time_in_pixels(outage)
      seconds_to_pixels(outage.start_datetime_on_date(date) - date.in_time_zone)
    end

    def seconds_to_pixels(seconds)
      seconds / (30 * 60) * ROW_INTERVAL_HEIGHT
    end

    # I got this from the accepted answer at:
    # http://stackoverflow.com/questions/19085937/finding-intervals-of-a-set-that-are-overlapping
    # I think the original answer was for open-open intervals. I think of open-
    # closed I need to swap the -1 and 1.
    def overlaps(outages)
      start_stop_list = outages.reduce([]) do |a, e|
        a << [e.start_datetime_utc, -1, e]
        a << [e.end_datetime_utc, 1, e]
      end.sort
      # .each do |x| puts "#{x[2].id} #{x[2].start_datetime_utc} #{x[1]}" }
      # TODO: Make this more closure-like.
      result = 0
      n = 0
      start_stop_list.each { |x| result += n if x[2] == -1; n -= x[2] }
    end
  end
end
