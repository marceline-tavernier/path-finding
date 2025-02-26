
class Cell {
  PVector position;
  char value;
  color col;

  Cell(PVector position, char value) {
    this.position = position;

    set_cell(value);
  }

  void draw(float cell_width, float cell_height) {
    float x = position.x * cell_width;
    float y = position.y * cell_height;
    fill(col);
    rect(x, y, cell_width, cell_height);

    fill(255);
    switch(value) {
    case '#':
      draw_grass(x, y, cell_width, cell_height);
      break;
    case '_':
      col = ROAD;
      break;
    case 'H':
      draw_hospital(x, y, cell_width, cell_height);
      break;
    case 'V':
      draw_victim(x, y, cell_width, cell_height);
      break;
    }
    
    noStroke();
  }

  void draw_grass(float x, float y, float cell_width, float cell_height) {
    float bladeWidth = cell_width * 0.1;
    float bladeHeight = cell_height * 0.8;
    float baseY = y + cell_height;

    float[][] blades = {
      {x + cell_width * 0.3, baseY, -10}, // Left blade
      {x + cell_width * 0.5, baseY, 0}, // Center blade
      {x + cell_width * 0.7, baseY, 10}    // Right blade
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

  void draw_hospital(float x, float y, float cell_width, float cell_height) {
    float margin_x = cell_width / 9;
    float margin_y = cell_height / 9;
    float bar_width = (cell_width - margin_x * 2) / 3;
    float bar_height = (cell_height - margin_y * 2) / 3;

    rect(x + margin_x, y + margin_y, bar_width, cell_height - margin_y * 2);
    rect(x + margin_x, y + cell_height / 2 - bar_height / 2, cell_width - margin_x * 2, bar_height);
    rect(x + cell_width - bar_width - margin_x, y + margin_y, bar_width, cell_height - margin_y * 2);
  }

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

  void set_cell(char value) {
    this.value = value;
    switch(value) {
    case '#':
      col = GRASS;
      break;
    case '_':
      col = ROAD;
      break;
    case 'H':
      col = HOSPITAL;
      break;
    case 'V':
      col = ROAD;
      break;
    }
  }
}

class Node {
  PVector position;
  float gCost;  // Cost from start to current node
  float hCost;  // Estimated cost from current node to goal
  Node parent = null;

  Node(PVector position, Node parent) {
    this.position = position;
    this.parent = parent;
    this.gCost = 0;
    this.hCost = 0;
  }

  // F-cost is the sum of gCost and hCost
  float getFCost() {
    return gCost + hCost;
  }

  @Override
    public boolean equals(Object obj) {
    if (this == obj) return true;
    if (obj == null || getClass() != obj.getClass()) return false;
    Node other = (Node) obj;
    return (int)this.position.x == (int)other.position.x &&
      (int)this.position.y == (int)other.position.y;
  }

  // Override hashCode to be consistent with equals
  @Override
    public int hashCode() {
    return Objects.hash((int)this.position.x, (int)this.position.y);
  }
}
