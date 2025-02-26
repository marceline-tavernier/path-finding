
PFont font;
Map map;
Player player;
ArrayList<Player> ai = new ArrayList<Player>();

void setup() {
  size(1000, 1000);
  font = createFont("DejaVu Sans Bold", 128);
  textSize(20);
  windowTitle("Artificial intelligence in games #2 : Planning and path finding");
  strokeWeight(3);

  String[] grid = {
    "#####################",
    "#___#_#_____#_____#_#",
    "#_#_#_#_###_#_###_#_#",
    "#_#_____#_#___#_____#",
    "#_#_#_###_#######_#_#",
    "#_#_#___#_________#_#",
    "#_#_#_#_#_###_#_#_#_#",
    "#___#_#___#___#___#_#",
    "#_#_#####_###_#####_#",
    "#_#_____#_#_#_____#_#",
    "#_#####_###___#_###_#",
    "#_____#_____#_#_____#",
    "####_##_#########_#_#",
    "#_______#_______#___#",
    "#_##_######_#_###_###",
    "#_#_________#___#___#",
    "#_#_###_#####_#_#_#_#",
    "#___#_#_#___#_#_#_#_#",
    "##_##_###_#_###_#_#_#",
    "#_________#_________#",
    "#####################"};

  map = new Map(grid);
  map.setup();

  for (int y = 0; y < map.grid_height; y++) {
    for (int x = 0; x < map.grid_width; x++) {
      PVector position = new PVector(x, y);
      if (map.get_cell(position).value == 'P') {
        player = new Player(map.grid_to_screen(new PVector(x + 0.5, y + 0.5)), false);
        map.set_cell(position, '_');
      }
      if (map.get_cell(position).value == 'A') {
        ai.add(new Player(map.grid_to_screen(new PVector(x + 0.5, y + 0.5)), true));
        map.set_cell(position, '_');
      }
    }
  }
}

void draw() {
  map.draw();
  player.draw();
  for (int i = 0; i < ai.size(); i++) {
    ai.get(i).draw();
  }

  if (millis() > 3000) {
    player.update_values();
    player.update_collision(map);
    for (int i = 0; i < ai.size(); i++) {
      ai.get(i).update_collision(map);
      ai.get(i).update_path();
    }
  } else {
    textFont(font);
    String counter = str(3 - (millis() / 1000));

    fill(0);
    rect(width / 2 - textWidth(counter) / 2 - 32, height / 2 - 128, textWidth(counter) + 64, 156);

    fill(255);
    text(counter, width / 2 - textWidth(counter) / 2, height / 2);
  }
}

void mousePressed() {
  PVector position = map.screen_to_grid(new PVector(mouseX, mouseY));
  if (map.get_cell(position).value == '_') {
    if (mouseButton == LEFT) {
      ai.add(new Player(map.grid_to_screen(new PVector(position.x + 0.5, position.y + 0.5)), true));
    } else if (mouseButton == RIGHT) {
      map.set_cell(position, 'V');
    }
  }
}

void keyPressed() {
  player.keyPressed();
}

void keyReleased() {
  player.keyReleased();
}
