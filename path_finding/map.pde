import java.util.*;

// The map class
class Map {

  // Variables
  int grid_width;
  int grid_height;
  float cell_width;
  float cell_height;

  ArrayList<ArrayList<Cell>> map = new ArrayList<ArrayList<Cell>>();
  PVector hospital_position = new PVector(0, 0);

  ArrayList<Player> occupied_cells = new ArrayList<Player>();

  // Constructor
  Map(String[] map) {
    this.grid_width = map[0].length();
    this.grid_height = map.length;
    this.cell_width = width / float(grid_width);
    this.cell_height = height / float(grid_height);

    for (int y = 0; y < grid_height; y++) {
      ArrayList<Cell> line = new ArrayList<Cell>();
      for (int x = 0; x < grid_width; x++) {
        line.add(new Cell(new PVector(x, y), false, map[y].charAt(x)));
      }
      this.map.add(line);
    }
  }

  // Setup
  void setup() {

    // Place a random hospital and remove other alternatives
    place_random_hospital();
    for (int y = 0; y < grid_height; y++) {
      for (int x = 0; x < grid_width; x++) {
        PVector position = new PVector(x, y);
        if (get_cell(position).value == 'H') {
          set_cell(position, '#');
        }
      }
    }
    set_cell(hospital_position, 'H');
  }

  // Place a random hospital and adjust roads around it
  void place_random_hospital() {

    // While the hospital position is not found, try another one
    PVector cell = new PVector(0, 0);
    do {
      float x = random(1, grid_width - 2);
      float y = random(1, grid_height - 2);
      cell.set(int(x), int(y));
    } while (get_cell(cell).value != 'H');

    // Save the hospital position and adjust roads around it
    hospital_position.set(cell.x, cell.y);
    set_cell(new PVector(cell.x, cell.y + 1), get_intersection_change(0, get_cell(new PVector(cell.x, cell.y + 1)).value));
    set_cell(new PVector(cell.x - 1, cell.y), get_intersection_change(1, get_cell(new PVector(cell.x - 1, cell.y)).value));
    set_cell(new PVector(cell.x, cell.y - 1), get_intersection_change(2, get_cell(new PVector(cell.x, cell.y - 1)).value));
    set_cell(new PVector(cell.x + 1, cell.y), get_intersection_change(3, get_cell(new PVector(cell.x + 1, cell.y)).value));
  }

  // Get the correction change in intersection based on hospital direction
  char get_intersection_change(int direction, char intersection) {

    // Check for the direction and modify intersection accordingly
    if (direction == 0) {
      if (intersection == '7' || intersection == '8' || intersection == '9') {
        return (char)(intersection - 3);
      }
      if (intersection == '-') {
        return '2';
      }
    }
    if (direction == 1) {
      if (intersection == '9' || intersection == '6' || intersection == '3') {
        return (char)(intersection - 1);
      }
      if (intersection == '|') {
        return '4';
      }
    }
    if (direction == 2) {
      if (intersection == '1' || intersection == '2' || intersection == '3') {
        return (char)(intersection + 3);
      }
      if (intersection == '-') {
        return '8';
      }
    }
    if (direction == 3) {
      if (intersection == '7' || intersection == '4' || intersection == '1') {
        return (char)(intersection + 1);
      }
      if (intersection == '|') {
        return '6';
      }
    }

    // If no conditions matched, return the intersection as is
    return intersection;
  }

  // Draw the roads
  void draw_roads() {
    for (int y = 0; y < grid_height; y++) {
      for (int x = 0; x < grid_width; x++) {
        if (map.get(y).get(x).is_road()) {
          map.get(y).get(x).draw(cell_width, cell_height);
        }
      }
    }
  }

  // Draw everything but roads
  void draw_map() {
    for (int y = 0; y < grid_height; y++) {
      for (int x = 0; x < grid_width; x++) {
        if (!map.get(y).get(x).is_road()) {
          map.get(y).get(x).draw(cell_width, cell_height);
        }
      }
    }
  }

  // Get the cell at grid position
  Cell get_cell(PVector grid_position) {
    return map.get(int(grid_position.y)).get(int(grid_position.x));
  }

  // Set the cell at grid position
  void set_cell(PVector grid_position, char value) {
    map.get(int(grid_position.y)).get(int(grid_position.x)).set_cell(value);
  }

  // Set the cell victim state at grid position
  void set_cell_victim(PVector grid_position, boolean has_victim) {
    map.get(int(grid_position.y)).get(int(grid_position.x)).set_victim(has_victim);
  }

  // Convert screen to grid position (int)
  PVector screen_to_grid(PVector screen_position) {
    return new PVector(int(screen_position.x * grid_width / width), int(screen_position.y * grid_height / height));
  }

  // Convert screen to grid position (float)
  PVector screen_to_grid_float(PVector screen_position) {
    return new PVector(screen_position.x * grid_width / width, screen_position.y * grid_height / height);
  }

  // Convert grid to screen position
  PVector grid_to_screen(PVector grid_position) {
    return new PVector(grid_position.x * width / grid_width, grid_position.y * height / grid_height);
  }

  // Check if a screen_position is colliding
  boolean is_colliding(PVector screen_position) {
    return get_cell(screen_to_grid(screen_position)).value == '#';
  }

  // Check if a cell is occupied
  boolean is_cell_occupied(PVector cell, Player ai) {

    // If it's the hospital, it's not
    if (cell.dist(hospital_position) == 0) {
      return false;
    }
    for (Player player : occupied_cells) {
      if (player != ai) {
        if (screen_to_grid(player.position).dist(cell) == 0) {

          // If there is a player in an intersection i want to go, stop
          if (get_cell(cell).is_intersection()) {
            return true;
          }

          // Or the player in the cell i want to go, stop
          if (!player.is_ai) {
            return true;
          }
        }

        // If there is an AI in front of me stop
        PVector to_player = PVector.sub(player.position, ai.position);
        float angle_in_front = degrees(PVector.angleBetween(ai.velocity.copy(), to_player));
        float angle_between = degrees(PVector.angleBetween(ai.velocity.copy(), player.velocity.copy()));
        if (player.position.dist(ai.position) < 50 && angle_between < 50 && angle_in_front < 50) {
          return true;
        }
      }
    }
    return false;
  }

  // Update the map by removing victims
  void update_map(Player player) {
    PVector grid_position = screen_to_grid(player.position);
    if (get_cell(grid_position).has_victim && !player.has_victim) {
      set_cell_victim(grid_position, false);
      player.has_victim = true;
    }
    if (get_cell(grid_position).value == 'H') {
      player.has_victim = false;
    }
  }

  // Get all victim on the map
  ArrayList<PVector> get_all_victims() {
    ArrayList<PVector> victims = new ArrayList<PVector>();
    for (int y = 0; y < grid_height; y++) {
      for (int x = 0; x < grid_width; x++) {
        if (get_cell(new PVector(x, y)).has_victim) {
          victims.add(new PVector(x, y));
        }
      }
    }
    return victims;
  }

  // A* pathfinding from start to goal cell
  ArrayList<PVector> find_path(PVector start, PVector goal) {

    // Setup pathfinding
    ArrayList<Node> open_list = new ArrayList<Node>();
    ArrayList<Node> closed_list = new ArrayList<Node>();

    Node start_cell = new Node(screen_to_grid(start), null);
    Node goal_cell = new Node(goal, null);

    open_list.add(start_cell);

    // While there is unexplored cells to visit
    while (open_list.size() > 0) {

      // Find the one with least cost
      Node current_cell = open_list.get(0);
      for (Node cell : open_list) {
        if (cell.get_f_cost() < current_cell.get_f_cost() ||
          (cell.get_f_cost() == current_cell.get_f_cost() && cell.hCost < current_cell.hCost)) {
          current_cell = cell;
        }
      }

      // If it's the goal
      if (current_cell.position.x == goal_cell.position.x && current_cell.position.y == goal_cell.position.y) {

        // Construct the path by backtracking the visited path
        ArrayList<PVector> path = new ArrayList<PVector>();
        Node current = current_cell;
        while (current != null) {
          path.add(new PVector(current.position.x + 0.5, current.position.y + 0.5));
          current = current.parent;
        }

        // Reverse the path for the correct direction and remove the current cell the AI is on to avoid looping
        Collections.reverse(path);
        if (path.size() >= 2 && (path.get(0).dist(screen_to_grid_float(start)) < 0.2 || path.get(1).dist(screen_to_grid_float(start)) <= 1)) {
          path.remove(0);
        }
        return path;
      }

      // Set the current cell as visited
      open_list.remove(current_cell);
      closed_list.add(current_cell);

      // Get all neighbors and add them to the list to visit
      for (PVector neighbor_position : get_neighbors(current_cell.position)) {
        if (get_cell(neighbor_position).value == '#') continue;

        Node neighbor_cell = new Node(neighbor_position, current_cell);

        if (closed_list.contains(neighbor_cell)) continue;

        // If it's not a wall and not already visited or added to the list to visit, calculate the cumulative cost
        float tentative_g_cost = current_cell.g_cost + 1;
        if (!open_list.contains(neighbor_cell)) {
          open_list.add(neighbor_cell);
        } else if (tentative_g_cost >= neighbor_cell.g_cost) {
          continue;
        }

        // If it has a victim, try to avoid it with a big cost
        neighbor_cell.g_cost = tentative_g_cost;
        if (get_cell(neighbor_cell.position).has_victim) {
          neighbor_cell.g_cost += 999;
        }

        // Calculate the heuristic cost
        neighbor_cell.hCost = heuristic(neighbor_cell.position, goal_cell.position);
      }
    }

    return new ArrayList<PVector>();
  }

  // Get all neighbors
  ArrayList<PVector> get_neighbors(PVector position) {
    ArrayList<PVector> neighbors = new ArrayList<PVector>();
    int x = int(position.x);
    int y = int(position.y);

    if (x > 0) neighbors.add(new PVector(x - 1, y));
    if (x < grid_width - 1) neighbors.add(new PVector(x + 1, y));
    if (y > 0) neighbors.add(new PVector(x, y - 1));
    if (y < grid_height - 1) neighbors.add(new PVector(x, y + 1));

    return neighbors;
  }

  // Calculate heuristic based on Manhattan distances
  float heuristic(PVector a, PVector b) {
    return abs(a.x - b.x) + abs(a.y - b.y);
  }
}
