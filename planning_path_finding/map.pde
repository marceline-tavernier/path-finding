import java.util.*;

color GRASS = color(0, 200, 50);
color ROAD = color(50, 50, 50);
color HOSPITAL = color(200, 0, 50);
color VICTIM = color(255, 255, 255);

class Map {
  int grid_width;
  int grid_height;
  float cell_width;
  float cell_height;

  ArrayList<ArrayList<Cell>> map = new ArrayList<ArrayList<Cell>>();
  PVector hospital_position = new PVector(0, 0);

  Map(String[] map) {
    this.grid_width = map[0].length();
    this.grid_height = map.length;
    this.cell_width = width / float(grid_width);
    this.cell_height = height / float(grid_height);

    for (int y = 0; y < grid_height; y++) {
      ArrayList<Cell> line = new ArrayList<Cell>();
      for (int x = 0; x < grid_width; x++) {
        line.add(new Cell(new PVector(x, y), map[y].charAt(x)));
      }
      this.map.add(line);
    }
  }

  void setup() {
    place_random('H', false, 1);
    place_random('V', true, 10);
    place_random('P', true, 1);
    place_random('A', true, 1);
  }
  
  void place_random(char value, boolean on_road, int amount) {
    for (int i = 0; i < amount; i++) {
      PVector cell = new PVector(0, 0);
      do {
        float x = random(1, grid_width - 2);
        float y = random(1, grid_height - 2);
        cell.set(int(x), int(y));
      } while ((on_road && get_cell(cell).value != '_') || (!on_road && get_cell(cell).value != '#'));
      set_cell(cell, value);
      if (value == 'H') {
        hospital_position.set(cell.x, cell.y);
      }
    }
  }

  void draw() {
    for (int y = 0; y < grid_height; y++) {
      for (int x = 0; x < grid_width; x++) {
        map.get(y).get(x).draw(cell_width, cell_height);
      }
    }
  }

  Cell get_cell(PVector grid_position) {
    return map.get(int(grid_position.y)).get(int(grid_position.x));
  }

  void set_cell(PVector grid_position, char value) {
    map.get(int(grid_position.y)).get(int(grid_position.x)).set_cell(value);
  }

  PVector screen_to_grid(PVector screen_position) {
    return new PVector(int(screen_position.x * grid_width / width), int(screen_position.y * grid_height / height));
  }

  PVector grid_to_screen(PVector grid_position) {
    return new PVector(grid_position.x * width / grid_width, grid_position.y * height / grid_height);
  }

  boolean is_colliding(PVector screen_position) {
    return get_cell(screen_to_grid(screen_position)).value == '#';
  }

  void update_map(Player player) {
    PVector grid_position = screen_to_grid(player.position);
    if (get_cell(grid_position).value == 'V' && !player.has_victim) {
      set_cell(grid_position, '_');
      player.has_victim = true;
    }
    if (get_cell(grid_position).value == 'H') {
      player.has_victim = false;
    }
  }

  ArrayList<PVector> get_all_victims() {
    ArrayList<PVector> victims = new ArrayList<PVector>();
    for (int y = 0; y < grid_height; y++) {
      for (int x = 0; x < grid_width; x++) {
        if (get_cell(new PVector(x, y)).value == 'V') {
          victims.add(new PVector(x, y));
        }
      }
    }
    return victims;
  }

  ArrayList<PVector> find_path(PVector start, PVector goal) {
    ArrayList<Node> open_list = new ArrayList<Node>();
    ArrayList<Node> closed_list = new ArrayList<Node>();

    Node startCell = new Node(start, null);
    Node goalCell = new Node(goal, null);

    open_list.add(startCell);

    while (open_list.size() > 0) {
      Node currentCell = open_list.get(0);
      for (Node Cell : open_list) {
        if (Cell.getFCost() < currentCell.getFCost() ||
          (Cell.getFCost() == currentCell.getFCost() && Cell.hCost < currentCell.hCost)) {
          currentCell = Cell;
        }
      }

      if (currentCell.position.x == goalCell.position.x && currentCell.position.y == goalCell.position.y) {
        ArrayList<PVector> path = new ArrayList<PVector>();
        Node current = currentCell;
        while (current != null) {
          path.add(new PVector(current.position.x + 0.5, current.position.y + 0.5));
          current = current.parent;
        }
        Collections.reverse(path);
        if (path.size() > 1) {
          path.remove(0);
        }
        return path;
      }

      open_list.remove(currentCell);
      closed_list.add(currentCell);

      for (PVector neighborPos : getNeighbors(currentCell.position)) {
        if (get_cell(neighborPos).value == '#') continue;

        Node neighborCell = new Node(neighborPos, currentCell);

        if (closed_list.contains(neighborCell)) continue;

        float tentativeGCost = currentCell.gCost + 1;
        if (!open_list.contains(neighborCell)) {
          open_list.add(neighborCell);
        } else if (tentativeGCost >= neighborCell.gCost) {
          continue;
        }

        neighborCell.gCost = tentativeGCost;
        if (get_cell(neighborCell.position).value == 'V') {
          neighborCell.gCost += 999;
        }
        neighborCell.hCost = heuristic(neighborCell.position, goalCell.position);
      }
    }

    return new ArrayList<PVector>();
  }

  ArrayList<PVector> getNeighbors(PVector position) {
    ArrayList<PVector> neighbors = new ArrayList<PVector>();
    int x = int(position.x);
    int y = int(position.y);

    if (x > 0) neighbors.add(new PVector(x - 1, y));  // Left
    if (x < grid_width - 1) neighbors.add(new PVector(x + 1, y));  // Right
    if (y > 0) neighbors.add(new PVector(x, y - 1));  // Up
    if (y < grid_height - 1) neighbors.add(new PVector(x, y + 1));  // Down

    return neighbors;
  }


  float heuristic(PVector a, PVector b) {
    return abs(a.x - b.x) + abs(a.y - b.y);
  }
}
