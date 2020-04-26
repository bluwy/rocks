# frozen_string_literal: true

require_relative 'sprite'

# The player ship
class Ship < Sprite
  attr_reader :health

  def initialize(window, space, laser_pool, specs)
    img = Gosu::Image.new('lib/assets/images/ship.png')
    radius = [img.width, img.height].max / 2.0
    body = CP::Body.new(specs[:mass], specs[:inertia])
    shape = CP::Shape::Circle.new(body, radius, CP::Vec2::ZERO)
    shape.collision_type = :ship
    shape.layers = CollisionLayer::SHIP
    shape.object = self

    super(space, img, shape, ZOrder::SHIP)

    @window = window
    @laser_pool = laser_pool
    @specs = specs

    @health = specs[:health]

    # Cache last shoot time to calculate shoot interval
    @last_shoot_ms = Gosu.milliseconds
  end

  def update
    update_position
    update_rotation
    shoot if @window.button_down?(Gosu::MS_LEFT) && can_shoot
  end

  def take_damage
    @health -= 1
  end

  def dead?
    @health <= 0
  end

  private

  def can_shoot
    if Gosu.milliseconds - @last_shoot_ms > @specs[:shoot_interval]
      @last_shoot_ms = Gosu.milliseconds
      true
    else
      false
    end
  end

  def update_position
    @shape.body.p.x = @shape.body.p.x.clamp(
      Constant::WINDOW_PADDING,
      @window.width - Constant::WINDOW_PADDING
    )

    @shape.body.p.y = @shape.body.p.y.clamp(
      Constant::WINDOW_PADDING,
      @window.height - Constant::WINDOW_PADDING
    )
  end

  def update_rotation
    @shape.body.a = Math.atan2(
      @window.mouse_y - @shape.body.p.y,
      @window.mouse_x - @shape.body.p.x
    )
  end

  def shoot
    laser = @laser_pool.spawn

    return if laser.nil?

    normalized_direction = CP::Vec2.new(
      @window.mouse_x - @shape.body.p.x,
      @window.mouse_y - @shape.body.p.y
    ).normalize_safe

    impulse = normalized_direction * -100.0

    @shape.body.apply_impulse(impulse, CP::Vec2::ZERO)

    laser.target_direction(@shape.body.p, normalized_direction)
  end
end
