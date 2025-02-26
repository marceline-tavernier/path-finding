
// Variables
int VECTOR_MULT = 50;
float MAX_SPEED = 1.5;
float MAX_FORCE = 1;
float MASS = 10;

///////////////////////

class Player {
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

  Player(PVector position, boolean isAI) {
    this.position = position;
    this.last_safe_position = new PVector(position.x, position.y);
    this.is_ai = isAI;
  }

  void draw() {
    pushMatrix();
    translate(position.x, position.y);
    float angle = atan2(velocity.y, velocity.x);
    rotate(angle);
    fill(255);
    stroke(255);
    if (is_ai) {
      fill(color(250, 250, 50));
      stroke(color(250, 250, 50));
    }
    if (has_victim) {
      if ((millis() / 250) % 2 == 0) {
        stroke(color(250, 0, 50));
      } else {
        stroke(color(50, 100, 250));
      }
    }
    triangle(12, 0, -8, 8, -8, -8);
    noStroke();
    popMatrix();
  }

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

  void update_collision(Map map) {
    if (map.is_colliding(position)) {
      position.set(last_safe_position.copy());
    } else {
      last_safe_position.set(position.copy());
    }
  }

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

  void move(PVector direction) {
    desired_velocity = direction.normalize().mult(MAX_SPEED);

    // Calculate steering
    steering = desired_velocity.copy().sub(velocity);
    steering.limit(MAX_FORCE).div(MASS);

    // Update velocity and position
    velocity.add(steering).limit(MAX_SPEED);
    position.add(velocity);

    map.update_map(this);
  }


  void update_path() {
    ArrayList<PVector> path = new ArrayList<PVector>();
    ArrayList<PVector> victims = map.get_all_victims();
    victims.sort((a, b) ->
      Float.compare(map.heuristic(map.screen_to_grid(position), a), map.heuristic(map.screen_to_grid(position), b))
      );
      
    if (has_victim || victims.size() == 0) {
      target_victim = new PVector(0, 0);
      path = map.find_path(map.screen_to_grid(position), map.hospital_position);
    } else {
      if ((map.get_cell(target_victim).value != 'V') /*|| (map.get_cell(target_victim).value == 'V' && victims.get(0).dist(map.screen_to_grid(position)) < target_victim.dist(map.screen_to_grid(position)))*/) {
        target_victim = victims.get(0);
      }
      path = map.find_path(map.screen_to_grid(position), target_victim);
    }
    if (path.size() > 0) {
      followPath(path);
    }
  }

  void followPath(ArrayList<PVector> newPath) {
    PVector target = map.grid_to_screen(newPath.get(0));
    move(target.copy().sub(position));
  }
}
