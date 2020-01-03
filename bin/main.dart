import 'dart:math';
import 'package:andy_bot/graph.dart';
import 'package:andy_bot/strategy.dart';

typedef WinCondition = bool Function(Player player);

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
    // Define a set of strategies
    final List<Strategy> strategies = <Strategy>[
      RandomWalk(Random(0)),
      Greedy(),
    ];
    // Run simulations with those strategies
    final Strategy strategy = strategies[0];
    final WinCondition winCondition =
        (Player player) => player.hasItem(Item.goal);
    final World world = World.simple(1);
    final Player player = world.player;
    print('start ${player.location} take ${player.location.item}');
    player.takeItem();
    // TODO: Prevent infinite loops.
    while (!winCondition(player)) {
      final Node goal = strategy.computeNextMove(player);
      print('-> $goal, take ${goal.item}');
      player.moveTo(goal);
    }
    print('Traveled: ${player.traveledPath}');
    // Compare average times.
  }
}

void main() {
  PrintPaths().main();
}
