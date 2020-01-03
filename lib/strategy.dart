import 'dart:math';

import 'graph.dart';
import 'path_finder.dart';

abstract class Strategy {
  // TODO: Should be a Move object or at least Edge.
  Node computeNextMove(Player player);
}

/// Always visits the cheapest unvisted node.
class Greedy implements Strategy {
  @override
  Node computeNextMove(Player player) {
    // TODO: Currently stateless, may "re-route" mid multi-node journey.
    // TODO: Computing all pairs shortest paths and caching would be faster.
    final List<Node> reachableNodes = player.reachableNodes().toList();
    MeasuredPath best;
    for (Node node in reachableNodes) {
      // Don't try to navigate to ourselves or somewhere w/o an item.
      if (node == player.location || !node.hasItem) {
        continue;
      }
      // Only looking at reachable nodes, never should be null.
      final MeasuredPath path = player.findPathTo(node);
      if (best == null || (path.cost < best.cost)) {
        best = path;
        // print(
        //     'going for ${best.nodes.last.item} @ ${best.nodes.last} cost ${best.cost}');
      }
    }
    return best.nodes.last;
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
