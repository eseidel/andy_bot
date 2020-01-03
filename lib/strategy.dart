import 'dart:math';
import 'package:andy_bot/graph.dart';

abstract class Strategy {
  // TODO: Should be a Move object or at least Edge.
  Node computeNextMove(Player player);
}

/// Always visits the cheapest unvisted node.
class Greedy implements Strategy {
  @override
  Node computeNextMove(Player player) {
    return null;
  }
}

class RandomWalk implements Strategy {
  RandomWalk([this._random]) {
    _random ??= Random();
  }
  Random _random;

  @override
  Node computeNextMove(Player player) {
    final Iterable<Node> reachable = player.location.reachableNeighbors(player);
    return reachable.toList()[_random.nextInt(reachable.length)];
  }
}
