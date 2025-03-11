
// The node class for pathfinding
class Node {

  // Variables
  PVector position;
  float g_cost;
  float hCost;
  Node parent = null;

  // Constructor
  Node(PVector position, Node parent) {
    this.position = position;
    this.parent = parent;
    this.g_cost = 0;
    this.hCost = 0;
  }

  // F-cost is the sum of gCost and hCost
  float get_f_cost() {
    return g_cost + hCost;
  }

  // Override equals to check if a node is equal to another
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
