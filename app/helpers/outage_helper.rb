module OutageHelper
  INTERVAL = 30.minutes

  def calendar(date = Date.today, start_date, end_date, &block)
    # puts date, start_date, end_date
    Calendar.new(self, date, start_date, end_date, block).table
  end

  def simple_outage_list(date, events)
    s = content_tag :p, date.day
    # puts s
    if events[date]
      s += content_tag :ul do
        debug = events[date].map do |event|
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

  def day_schedule_outage_list(date, events)
    content_tag :div, class: "day-by-half-hour" do
      s = content_tag :p, date.day
      s += content_tag :ul do
        (0...((date.to_time + 1.day) - date.to_time)).step(INTERVAL).map do |half_hour|
          # puts date + time.seconds
          content_tag :li do
            time = (date.in_time_zone + half_hour)
            a = []
            a << time.strftime("%H:%M")
            a << day_schedule_outage(time, events[date])
            a.join.html_safe
          end
        end.join.html_safe
      end
      # puts s
      s
    end
  end

  def day_schedule_outage(time, outages)
    return unless outages
    # puts "Outages: " + outages.length.to_s
    # puts "Date: " + time.to_date.to_s
    # puts "Start time: " + time.to_s
    outages.select do |event|
      # puts "#{event.start_datetime_utc.in_time_zone}, #{event.end_datetime_utc.in_time_zone}"
      # puts "#{event.start_datetime_on_date(time.to_date)}, #{event.end_datetime_on_date(time.to_date)}"
      # puts "#{time}, #{time + INTERVAL}"
      # puts((time...time + INTERVAL).cover?(event.start_datetime_on_date(time.to_date)) ? "true": "false")
      (time...time + INTERVAL)
        .cover? event.start_datetime_on_date(time.to_date)
    end.map do |event|
      content_tag(:span, link_to(event.title, event), class: "outage title bg-info")
    end
  end

  class Calendar < Struct.new(:view, :date, :start_date, :end_date, :callback)
    HEADER = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday).freeze
    START_DAY = :sunday

    delegate :content_tag, to: :view

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
end
