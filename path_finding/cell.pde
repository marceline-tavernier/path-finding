
// Variables
color GRASS = color(0, 200, 50);
color ROAD = color(50, 50, 50);
color HOSPITAL = color(200, 0, 50);
color VICTIM = color(255, 255, 255);

///////////////////

// The cell class
class Cell {

  // Variables
  PVector position;
  boolean has_victim;
  char value;
  color col;

  // Constructor
  Cell(PVector position, boolean has_victim, char value) {
    this.position = position;
    this.has_victim = has_victim;

    set_cell(value);
  }

  // Draw the cell
  void draw(float cell_width, float cell_height) {
    float x = position.x * cell_width;
    float y = position.y * cell_height;
    fill(col);
    rect(x, y, cell_width, cell_height);

    fill(255);
    if (value == '#') {
      draw_grass(x, y, cell_width, cell_height);
    } else if (value == '-' || value == '|' || Character.isDigit(value)) {
      draw_road(value, x, y, cell_width, cell_height);
    } else if (value == 'H') {
      draw_hospital(x, y, cell_width, cell_height);
    }

    if (has_victim) {
      draw_victim(x, y, cell_width, cell_height);
    }

    noStroke();
  }

  // Draw a grass cell
  void draw_grass(float x, float y, float cell_width, float cell_height) {
    float bladeWidth = cell_width * 0.1;
    float bladeHeight = cell_height * 0.8;
    float baseY = y + cell_height;

    float[][] blades = {
      {x + cell_width * 0.3, baseY, -10},
      {x + cell_width * 0.5, baseY, 0},
      {x + cell_width * 0.7, baseY, 10}
    };

    fill(34, 139, 34);

    for (float[] blade : blades) {
      float topX = blade[0] + blade[2];
      float topY = blade[1] - bladeHeight;

      beginShape();
      vertex(blade[0] - bladeWidth / 2, blade[1]);
      vertex(blade[0] + bladeWidth / 2, blade[1]);
      vertex(topX, topY);
      endShape(CLOSE);
    }
  }

  // Draw a road cell
  void draw_road(char type, float x, float y, float cell_width, float cell_height) {
    if (type == '|') {
      rect(x + 0.5 * cell_width - cell_width / 15 / 2, y + cell_height / 15, cell_width / 15, cell_height - cell_height / 15 * 2);
    } else if (type == '-') {
      rect(x + cell_width / 15, y + 0.5 * cell_height - cell_height / 15 / 2, cell_width - cell_width / 15 * 2, cell_height / 15);
    } else if (type == '1') {
      rect(x + cell_width / 2 - cell_width / 15 / 2, y + 0.5 * cell_height - cell_height / 15 / 2, 0.5 * cell_width - cell_width / 15 / 2, cell_height / 15);
      rect(x + 0.5 * cell_width - cell_width / 15 / 2, y + cell_height / 15, cell_width / 15, 0.5 * cell_height - cell_height / 15);
    } else if (type == '2') {
      rect(x + cell_width / 15, y + 0.5 * cell_height - cell_height / 15 / 2, cell_width - cell_width / 15 * 2, cell_height / 15);
      rect(x + 0.5 * cell_width - cell_width / 15 / 2, y + cell_height / 15, cell_width / 15, 0.5 * cell_height - cell_height / 15);
    } else if (type == '3') {
      rect(x + cell_width / 15, y + 0.5 * cell_height - cell_height / 15 / 2, 0.5 * cell_width - cell_width / 15 / 2, cell_height / 15);
      rect(x + 0.5 * cell_width - cell_width / 15 / 2, y + cell_height / 15, cell_width / 15, 0.5 * cell_height - cell_height / 15);
    } else if (type == '4') {
      rect(x + 0.5 * cell_width - cell_width / 15 / 2, y + cell_height / 15, cell_width / 15, cell_height - cell_height / 15 * 2);
      rect(x + 0.5 * cell_width, y + 0.5 * cell_height - cell_height / 15 / 2, 0.5 * cell_width - cell_width / 15, cell_height / 15);
    } else if (type == '5') {
      rect(x + 0.5 * cell_width - cell_width / 15 / 2, y + cell_height / 15, cell_width / 15, cell_height - cell_height / 15 * 2);
      rect(x + cell_width / 15, y + 0.5 * cell_height - cell_height / 15 / 2, cell_width - cell_width / 15 * 2, cell_height / 15);
    } else if (type == '6') {
      rect(x + 0.5 * cell_width - cell_width / 15 / 2, y + cell_height / 15, cell_width / 15, cell_height - cell_height / 15 * 2);
      rect(x + cell_width / 15, y + 0.5 * cell_height - cell_height / 15 / 2, 0.5 * cell_width - cell_width / 15, cell_height / 15);
    } else if (type == '7') {
      rect(x + cell_width / 2 - cell_width / 15 / 2, y + 0.5 * cell_height - cell_height / 15 / 2, 0.5 * cell_width - cell_width / 15 / 2, cell_height / 15);
      rect(x + 0.5 * cell_width - cell_width / 15 / 2, y + 0.5 * cell_height, cell_width / 15, 0.5 * cell_height - cell_height / 15);
    } else if (type == '8') {
      rect(x + cell_width / 15, y + 0.5 * cell_height - cell_height / 15 / 2, cell_width - cell_width / 15 * 2, cell_height / 15);
      rect(x + 0.5 * cell_width - cell_width / 15 / 2, y + 0.5 * cell_height, cell_width / 15, 0.5 * cell_height - cell_height / 15);
    } else if (type == '9') {
      rect(x + cell_width / 15, y + 0.5 * cell_height - cell_height / 15 / 2, 0.5 * cell_width - cell_width / 15 / 2, cell_height / 15);
      rect(x + 0.5 * cell_width - cell_width / 15 / 2, y + 0.5 * cell_height, cell_width / 15, 0.5 * cell_height - cell_height / 15);
    }
  }

  // Draw the hospital
  void draw_hospital(float x, float y, float cell_width, float cell_height) {
    float margin_x = cell_width / 9;
    float margin_y = cell_height / 9;
    float bar_width = (cell_width - margin_x * 2) / 3;
    float bar_height = (cell_height - margin_y * 2) / 3;

    rect(x + margin_x, y + margin_y, bar_width, cell_height - margin_y * 2);
    rect(x + margin_x, y + cell_height / 2 - bar_height / 2, cell_width - margin_x * 2, bar_height);
    rect(x + cell_width - bar_width - margin_x, y + margin_y, bar_width, cell_height - margin_y * 2);
  }

  // Draw a victim
  void draw_victim(float x, float y, float cell_width, float cell_height) {
    float width_length = cell_width / 3;
    float height_length = cell_height / 3;

    stroke(255);
    circle(x + width_length, y + height_length, width_length);
    line(x + width_length * 2, y + height_length, x + width_length, y + height_length * 2);
    line(x + width_length, y + height_length, x + width_length * 2, y + height_length * 2);
    line(x + width_length * 2, y + height_length * 2, x + cell_width, y + height_length * 2);
    line(x + width_length * 2, y + height_length * 2, x + width_length * 2, y + cell_height);
  }

  // Set the cell to the value
  void set_cell(char value) {
    this.value = value;

    // Update the background color
    if (value == '#') {
      col = GRASS;
    } else if (value == '-' || value == '|' || Character.isDigit(value)) {
      col = ROAD;
    } else if (value == 'H') {
      col = HOSPITAL;
    }
  }

  // Add/remove a victim from the cell
  void set_victim(boolean has_victim) {
    this.has_victim = has_victim;
  }


  // Check if it's a road
  boolean is_road() {
    return value == '-' || value == '|' || Character.isDigit(value);
  }

  // check if it's an intersection
  boolean is_intersection() {
    return Character.isDigit(value);
  }
}
