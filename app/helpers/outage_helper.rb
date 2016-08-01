module OutageHelper
  def calendar(date = Date.today, start_date, end_date, &block)
    # puts date, start_date, end_date
    Calendar.new(self, date, start_date, end_date, block).table
  end

  def simple_outage_list(date, events)
    # delegate :content_tag, to: self
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
    s = content_tag :p, date.day
    s += content_tag :ul do
      t = Time.new(2016, 7, 29, 8)
      (0.minutes...2.hours).step(15.minutes).map do |time|
        puts t + time
        content_tag :li, (t + time).strftime("%H:%M")
      end.join.html_safe
    end
    puts s
    s
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
      # first = date.beginning_of_month.beginning_of_week(START_DAY)
      # last = date.end_of_month.end_of_week(START_DAY)
      first = start_date
      last = end_date
      # puts((first...last).to_a.in_groups_of(7).inspect)
      (first...last).to_a.in_groups_of(7, false)
    end
  end
end
