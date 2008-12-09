#
# Ruby/ProgressBar - a text progress bar library
#
# Copyright (C) 2001 Satoru Takabayashi <satoru@namazu.org>
#     All rights reserved.
#     This is free software with ABSOLUTELY NO WARRANTY.
#
# You can redistribute it and/or modify it under the terms
# of Ruby's licence.
#

class ProgressBar
  VERSION = "0.3"

  attr_accessor :colorer
  attr_writer :title
  
  def initialize (title, total, out = STDERR)
    @title = title
    @total = total
    @out = out
    @current = 0
    @previous = 0
    @is_finished = false
    @start_time = Time.now
    show_progress
  end

  def inspect
    "(ProgressBar: #{@current}/#{@total})"
  end

  def format_time (t)
    t = t.to_i
    sec = t % 60
    min  = (t / 60) % 60
    hour = t / 3600
    sprintf("%02d:%02d:%02d", hour, min, sec);
  end

  # ETA stands for Estimated Time of Arrival.
  def eta
    if @current == 0
      "ETA:  --:--:--"
    else
      elapsed = Time.now - @start_time
      eta = elapsed * @total / @current - elapsed;
      sprintf("ETA: %s", format_time(eta))
    end
  end

  def elapsed
    elapsed = Time.now - @start_time
    sprintf("Time: %s", format_time(elapsed))
  end
  
  def time
    if @is_finished then elapsed else eta end
  end

  def eol
    if @is_finished then "\n" else "\r" end
  end

  def bar(percentage)
    @bar = "=" * 41
    len = percentage * (@bar.length + 1) / 100
    sprintf("[%.*s%s%*s]", len, @bar, ">", [@bar.size - len, 0].max, "")
  end

  def show (percentage)
    output = sprintf("%-25s %3d%% %s %s%s", 
    @title[0,25], 
    percentage, 
    bar(percentage),
    time,
    eol
    )
    
    unless @colorer.nil?
      output = colorer.call(output)
    end
      
    @out.print(output)
  end

  def show_progress
    if @total.zero?
      cur_percentage = 100
      prev_percentage = 0
    else
      cur_percentage  = (@current  * 100 / @total).to_i
      prev_percentage = (@previous * 100 / @total).to_i
    end

    if cur_percentage > prev_percentage || @is_finished
      show(cur_percentage)
    end
  end

  public
  def finish
    @current = @total
    @is_finished = true
    show_progress
  end

  def set (count)
    if count < 0 || count > @total
      raise "invalid count: #{count} (total: #{total})"
    end
    @current = count
    show_progress
    @previous = @current
  end

  def inc (step = 1)
    @current += step
    @current = @total if @current > @total
    show_progress
    @previous = @current
  end
end

