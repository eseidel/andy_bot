import 'dart:math';
import 'package:andy_bot/graph.dart';
import 'package:andy_bot/strategy.dart';
import 'package:andy_bot/maps.dart';

class CompareStrategies {
  MeasuredPath runOnce(World world, Strategy strategy) {
    final Player player = world.player;
    // TODO: Use package:logging to have levels.
    // print('start ${player.location} take ${player.location.item}');
    player.takeItem();
    // TODO: Prevent infinite loops.
    while (!world.winCondition(player)) {
      final Node goal = strategy.computeNextMove(player);
      // print('-> $goal, take ${goal.item}');
      player.moveTo(goal);
    }
    // print('${strategy.runtimeType} traveled ${player.traveledPath}');
    return player.traveledPath;
  }

  void main() {
    // Define a set of strategies
    final Strategy random = RandomWalk(Random(0));
    final Strategy greedy = Greedy();
    // Run simulations with those strategies
    const int runCount = 100;
    int totalDiff = 0;
    for (int i = 0; i < runCount; i++) {
      // Using the index as the world seed for consistency.
      final MeasuredPath randomPath = runOnce(createSimpleWorld(i), random);
      final MeasuredPath greedyPath = runOnce(createSimpleWorld(i), greedy);
      final int diff = randomPath.cost - greedyPath.cost;
      totalDiff += diff;
    }
    final double averageDiff = totalDiff / runCount;
    print(
        'Greedy averages $averageDiff better than random over $runCount runs.');
  }
}

void main() {
  CompareStrategies().main();
}
