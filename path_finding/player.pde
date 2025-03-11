
// Variables
int VECTOR_MULT = 50;
float MAX_SPEED = 1.5;
float MAX_FORCE = 1;
float MASS = 10;

///////////////////////

// The player and AI class
class Player {

  // Variables
  PVector position;
  PVector last_safe_position;

  PVector velocity = new PVector(0, 0);
  PVector desired_velocity = new PVector(0, 0);
  PVector steering = new PVector(0, 0);

  boolean is_ai = false;
  boolean has_victim = false;
  PVector target_victim  = new PVector(0, 0);
  boolean up = false;
  boolean down = false;
  boolean left = false;
  boolean right = false;

  // Constructor
  Player(PVector position, boolean isAI) {
    this.position = position;
    this.last_safe_position = new PVector(position.x, position.y);
    this.is_ai = isAI;
  }

  // Draw the player as triangle and AI as rectangle to the right of the road
  void draw() {
    pushMatrix();
    translate(position.x, position.y);
    float angle = atan2(velocity.y, velocity.x);
    rotate(angle);
    fill(color(0, 250, 250));
    stroke(color(0, 250, 250));
    if (is_ai) {
      fill(color(250, 250, 0));
      stroke(color(250, 250, 0));
    }
    if (has_victim) {
      if ((millis() / 250) % 2 == 0) {
        stroke(color(250, 0, 50));
      } else {
        stroke(color(50, 100, 250));
      }
    }
    if (is_ai) {
      rect(-0.064 * map.cell_width, map.cell_height / 5, 0.192 * map.cell_width, 0.12 * map.cell_height);
    } else {
      triangle(12, 0, -8, 8, -8, -8);
    }
    noStroke();
    popMatrix();
  }

  // Handle key press and key release
  void keyPressed() {
    if (key == 'z') {
      up = true;
    }
    if (key == 's') {
      down = true;
    }
    if (key == 'q') {
      left = true;
    }
    if (key == 'd') {
      right = true;
    }
  }

  void keyReleased() {
    if (key == 'z') {
      up = false;
    }
    if (key == 's') {
      down = false;
    }
    if (key == 'q') {
      left = false;
    }
    if (key == 'd') {
      right = false;
    }
  }

  // Handle collision and rollback if it's inside a wall
  void update_collision(Map map) {
    if (map.is_colliding(position)) {
      position.set(last_safe_position.copy());
    } else {
      last_safe_position.set(position.copy());
    }
  }

  // Update values to move
  void update_values() {
    int vertical = 0;
    if (up && !down) {
      vertical = -1;
    } else if (down && !up) {
      vertical = 1;
    }

    int horizontal = 0;
    if (left && !right) {
      horizontal = -1;
    } else if (right && !left) {
      horizontal = 1;
    }

    move(new PVector(horizontal, vertical));
  }

  // Move the player/AI
  void move(PVector direction) {
    desired_velocity = direction.normalize().mult(MAX_SPEED);

    // Calculate steering
    steering = desired_velocity.copy().sub(velocity);
    steering.limit(MAX_FORCE).div(MASS);

    // If the angle between steering and current velocity is more than 135° (and is AI)
    if (is_ai && PVector.angleBetween(steering, velocity) >= 0.75 * PI) {
      float angle = -HALF_PI;

      // Limit the steering angle and always the correct way
      steering.lerp(PVector.fromAngle(angle).mult(steering.mag()).rotate(velocity.heading()), 0.5);
    }

    // Update velocity and position
    velocity.add(steering).limit(MAX_SPEED);
    position.add(velocity);
    
    // Update the map to see if there is a victim to pick up
    map.update_map(this);
  }

  // Update the path finding
  void update_path() {

    // Update the map first to see if there is a victim to pick up
    map.update_map(this);

    ArrayList<PVector> path = new ArrayList<PVector>();

    // Get all victims and sort by distance
    ArrayList<PVector> victims = map.get_all_victims();
    victims.sort((a, b) ->
      Float.compare(map.heuristic(map.screen_to_grid(position), a), map.heuristic(map.screen_to_grid(position), b))
      );

    // If it has a victim or no victim left, go to the hospital
    if (has_victim || victims.size() == 0) {
      target_victim = new PVector(0, 0);
      path = map.find_path(position, map.hospital_position);
    }

    // Else go to the closest one
    else {
      if (!map.get_cell(target_victim).has_victim) {
        target_victim = victims.get(0);
      }
      path = map.find_path(position, target_victim);
    }

    // If there is a path found
    if (path.size() > 0) {

      // If the cell is not occupied, follow the path
      PVector next_cell = map.grid_to_screen(path.get(0));
      PVector next_grid_position = map.screen_to_grid(next_cell);
      if (!map.is_cell_occupied(next_grid_position, this)) {
        follow_path(path);
      }
    }
  }

  // Follow the path by moving to the first cell
  void follow_path(ArrayList<PVector> path) {
    PVector target = map.grid_to_screen(path.get(0));
    move(target.copy().sub(position));
  }
}
