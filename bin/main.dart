import 'package:andy_bot/graph.dart';

class PrintPaths {
  PrintPaths();

  World world = World.simple();

  void printPath(Node start, Node end) {
    final MeasuredPath path = world.findPath(start, end);
    if (path == null) {
      print('$end unreachable from $start');
      return;
    }
    print(path.nodes.map((Node n) => n.name).join(' -> ') + ' ${path.cost}');
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
