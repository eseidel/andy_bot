import 'package:andy_bot/graph.dart';

class PrintPaths {
  PrintPaths();

  World world = World();

  void printPath(Node start, Node end) {
    final List<Node> path = world.findPath(start, end).toList();
    if (path.isEmpty) {
      print('$end unreachable from $start');
      return;
    }
    // This is silly, but it's hard to get the cost out of the A* we're using.
    int cost = 0;
    for (int x = 1; x < path.length; x++) {
      cost += path[x - 1].edgeTo(path[x]).cost;
    }
    print(path.map((Node n) => n.name).join(' -> ') + ' $cost');
  }

  void printAllPossiblePaths() {
    final Node start = world.player.location;
    for (Node end in world.nodes) {
      printPath(start, end);
    }
  }

  void main() {
    print('$world');
    print('player at ${world.player.location}');
    printAllPossiblePaths();
    world.player.location = world.node('C');
    printAllPossiblePaths();
  }
}

void main() {
  PrintPaths().main();
}
