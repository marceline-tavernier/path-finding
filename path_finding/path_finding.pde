
// Variables
PFont font;
Map map;
Player player;
ArrayList<Player> ai = new ArrayList<Player>();

///////////////////////

// Setup
void setup() {

  // Setup size, font, title and drawing mode
  size(1000, 1000);
  font = createFont("DejaVu Sans Bold", 128);
  textSize(20);
  windowTitle("Artificial intelligence in games #2 : Path finding");
  strokeWeight(3);
  noStroke();

  // The map
  String[] grid = {
    "#H#####H##H#",
    "H7-----9H-9H",
    "#|##H##|##|#",
    "#|##H##|##|#",
    "H4--8--5--3H",
    "#|##|##|##H#",
    "#H##|##|##H#",
    "H7--2--2--9H",
    "#|##H##H##|#",
    "#|###|####|#",
    "H1---2----3H",
    "#H###H####H#"};

  // Setup the map
  map = new Map(grid);
  map.setup();

  // Spawn the player and AIs in a random position
  PVector position = get_random_spawing_pos();
  player = new Player(map.grid_to_screen(new PVector(position.x + 0.5, position.y + 0.5)), false);
  for (int i = 0; i < 3; i++) {
    PVector ai_position = get_random_spawing_pos();
    ai.add(new Player(map.grid_to_screen(new PVector(ai_position.x + 0.5, ai_position.y + 0.5)), true));
  }
}

// Get a random spawing position
PVector get_random_spawing_pos() {
  PVector position = new PVector(0, 0);
  do {
    float a = random(1, map.grid_width - 2);
    float b = random(1, map.grid_height - 2);
    position.set(int(a), int(b));
  } while (map.get_cell(position).value == '#');
  return position;
}

// Draw everything
void draw() {

  // Clear occupied cells
  map.occupied_cells.clear();

  // Draw the roads
  map.draw_roads();

  // Draw all the AIs and add them to the occupied cells
  for (int i = 0; i < ai.size(); i++) {
    ai.get(i).draw();
    map.occupied_cells.add(ai.get(i));
  }

  // Draw the rest of the map
  map.draw_map();

  // Draw the player and add it to the occupied cells
  player.draw();
  map.occupied_cells.add(player);

  // If we are after the 3 seconds countdown, update all values for player and AIs
  if (millis() > 3000) {
    player.update_values();
    player.update_collision(map);
    for (int i = 0; i < ai.size(); i++) {
      ai.get(i).update_path();
    }
  }

  // Else draw the countdown
  else {
    textFont(font);
    String counter = str(3 - (millis() / 1000));

    fill(0);
    rect(width / 2 - textWidth(counter) / 2 - 32, height / 2 - 128, textWidth(counter) + 64, 156);

    fill(255);
    text(counter, width / 2 - textWidth(counter) / 2, height / 2);
  }
}

// If the mouse is pressed
void mousePressed() {
  PVector position = map.screen_to_grid(new PVector(mouseX, mouseY));

  // If it's a road and it's not occupied
  if (map.get_cell(position).is_road()) {
    for (Player ai : map.occupied_cells) {
      if (map.screen_to_grid(ai.position).dist(position) == 0) {
        return;
      }
    }

    // If left click, spawn an AI
    if (mouseButton == LEFT) {
      Player new_ai = new Player(map.grid_to_screen(new PVector(position.x + 0.5, position.y + 0.5)), true);
      ai.add(new_ai);
      map.occupied_cells.add(new_ai);
    }

    // If right click, spawn a victim
    else if (mouseButton == RIGHT) {
      map.set_cell_victim(position, true);
    }
  }
}

// Handle player key press an key release
void keyPressed() {
  player.keyPressed();
}

void keyReleased() {
  player.keyReleased();
}
