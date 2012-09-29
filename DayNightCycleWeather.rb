#==============================================================================
# DayNightCycle
#==============================================================================

# Public: This class is responsible for the day / night cycle in a game.
class DayNightCycle
  # Public: The color tones for the corresponding day / night times.
  module Tones
    DUSK    = Tone.new(-119, -85, -34, 68)
    MORNING = Tone.new(-40, -30, -34, 20)
    NOON    = Tone.new(0, 0, 0, 0)
    EVENING = Tone.new(-70, -60, -30, 200)
    NIGHT   = Tone.new(-119, -95, -64, 255)
  end

  # Public: The switch of a day time takes 1000 frames.
  SWITCH_DURATION = 300

  # Public: Speed of ticks (1 is normal, 50 is very fast).
  TICK_SPEED = 1

  # Public: Every minute takes 50 frames.
  MINUTE_TICK = (50 / TICK_SPEED)

  # Public: Initialize frame count and start time of the day.
  def initialize
    @frame_count = 0
    set_time(9, 00)
  end

  # Public: Changes the screen tone according to the time of day.
  #
  # day_time - The time of the day, e. g. dusk, morning, night, etc.
  #
  # Examples
  #
  #   # Switches the tone to morning
  #   day_night_cycle.switch_tone(:morning)
  def switch_tone(day_time)
    case day_time.to_sym
      when :dusk
        @screen.start_tone_change(DayNightCycle::Tones::DUSK, SWITCH_DURATION)
      when :morning
        @screen.start_tone_change(DayNightCycle::Tones::MORNING, SWITCH_DURATION)
      when :noon
        @screen.start_tone_change(DayNightCycle::Tones::NOON, SWITCH_DURATION)
      when :evening
        @screen.start_tone_change(DayNightCycle::Tones::EVENING, SWITCH_DURATION)
      when :night
        @screen.start_tone_change(DayNightCycle::Tones::NIGHT, SWITCH_DURATION)
    end
  end

  # Public: Set a specific time.
  #
  # hours   - The hours to be set.
  # minutes - The minutes to be set.
  def set_time(hours, minutes)
    @hours   = hours
    @minutes = minutes
  end

  # Public: Outputs the time.
  def print_time
    puts "HOURS", @hours
    puts "MINUTES", @minutes
  end

  # Public: Is it dusk?
  #
  # Returns true if dusk, otherwise false.
  def dusk?
    @hours == 5
  end

  # Public: Is it night?
  #
  # Returns true if night, otherwise false.
  def night?
    @hours == 20
  end

  # Public: Is it morning?
  #
  # Returns true if morning, otherwise false.
  def morning?
    @hours == 9
  end

  # Public: Is it noon?
  #
  # Returns true if noon, otherwise false.
  def noon?
    @hours == 12
  end

  # Public: Is it evening?
  #
  # Returns true if evening, otherwise false.
  def evening?
    @hours == 17
  end

  # Public: 60 minutes are 1 hour.
  #
  # Returns true if max amount of minutes reached, otherwise false.
  def max_minutes_reached?
    @minutes >= 60
  end

  # Public: 24 hours are one day.
  #
  # Returns true if max amount of hours reached, otherwise false.
  def max_hours_reached?
    @hours >= 24
  end

  # Public: Updates the screen. Not used right now, needs to be overwritten.
  def update_screen
  end

  # Public: Update frame values, count the time and switch the tone if
  # appropriate.
  def update
    @screen       = $game_map.screen unless @screen
    @frame_count += 1

    # If the minute tick is reached via frames increment the minutes.
    @minutes += 1 if (@frame_count % MINUTE_TICK == 0)

    # Reset minutes and increment hours.
    if max_minutes_reached?
      @minutes = 0
      @hours += 1
    end

    # Reset hours.
    @hours = 0 if max_hours_reached?

    # Dusk is reached?
    switch_tone(:dusk) if dusk?

    # Noon is reached?
    switch_tone(:morning) if morning?

    # Noon is reached?
    switch_tone(:noon) if noon?

    # Noon is reached?
    switch_tone(:evening) if evening?

    # Night is reached?
    switch_tone(:night) if night?
  end
end

#==============================================================================
# WeatherSystem
#==============================================================================

# Public: This class is responsible for the weather system.
class WeatherSystem
  @current_weather = nil

  # Public: Initializes the current weather.
  #
  # weather - The weather to be set from the start.
  #
  # Examples
  #
  #   # Available: :none, :rain, :storm, :snow
  #   WeatherSystem.new(:rain)
  def initialize(type = :none)
    @current_weather = type
  end

  # Public: Changes the weather type.
  #
  # type - The type of weather to be set.
  #
  # Examples
  #
  #   # Available: :none, :rain, :storm, :snow
  #   weather_system.change_weather(:storm)
  def change_weather(type)
    screen = $game_map.screen
    screen.change_weather(type, 2, 10)
  end

  # Public: Updates the screen. Not used right now, needs to be overwritten.
  def update_screen
  end

  # Public: The update method that occasionally changes the weather.
  def update
    unless raining?
      change_weather(:rain) if (rand(1000000) > 995999)
      @current_weather = :rain
    else
      change_weather(:none) if (rand(1000000) > 995999)
      @current_weather = :none
    end
  end

  # Public: Is it raining right now?
  #
  # Returns true if it is raining, otherwise false.
  def raining?
    @current_weather == :rain
  end
end

#==============================================================================
# Game_System
#==============================================================================

# Public: The main game system. Here we make our systems accessible for the
# entire application.
class Game_System
  attr_accessor :day_night_cycle
  attr_accessor :weather_system

  # Public: Create accessible instance variables for the weather and day and
  # night system.
  def initialize
    @day_night_cycle = DayNightCycle.new
    @weather_system  = WeatherSystem.new
  end
end

#==============================================================================
# Scene_Map
#==============================================================================

# Public: This class handles the scene-related elements of the map, such as
# setting up the message window and calling various menus that would change the
# "Scene".
class Scene_Map
  alias day_night_main main
  alias weather_main main

  # Public: Overwrites the main method of the Scene Map to be able to hook in
  # the update screen methods of the day night cycle and weather system.
  def main
    $game_system.day_night_cycle.update_screen
    $game_system.weather_system.update_screen
    day_night_main
    weather_main
  end

  alias day_night_update update
  alias weather_update update

  # Public: Overwrites the main update of the Scene Map to be able to hook in
  # the update methods of the day night cycle and weather system.
  def update
    $game_system.day_night_cycle.update
    $game_system.weather_system.update
    day_night_update
    weather_update
  end
end
