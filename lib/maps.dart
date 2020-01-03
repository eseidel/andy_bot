import 'dart:math';
import 'graph.dart';

// Could use built_value for something fancier:
// https://github.com/google/built_value.dart/blob/master/example/lib/enums.dart
class SimpleItem implements Item {
  const SimpleItem(this.id);
  final int id;

  static const SimpleItem goal = SimpleItem(0);
  static const SimpleItem redKey = SimpleItem(1);
  static const SimpleItem junk = SimpleItem(2);
}

class SimpleItemPool extends ItemPool {
  @override
  List<Item> requiredItems = <SimpleItem>[
    SimpleItem.goal,
    SimpleItem.redKey,
  ];

  final List<Item> _fillItems = <SimpleItem>[
    SimpleItem.junk,
  ];

  @override
  Iterable<Item> generateFillerItems(Random random, int count) {
    // This shouldn't need to be here, but if we use List<Item>.generate
    // in the baseclass instead, then the runtime throws a type exception?
    return List<SimpleItem>.generate(
        count, (int _) => pickOne(random, _fillItems));
  }
}

// Diagram: https://docs.google.com/drawings/d/1YJdXb9xBr0QRxe7666wHTwRLNNWSxriLlLl-JbAkqUg/edit?folder=0AFC4tS7Ao1fIUk9PVA
Node buildSimpleMap(World w) {
  w.addNode('A');
  w.addNode('B');
  w.addNode('C');
  w.addNode('D');
  w.addNode('E');
  w.addNode('F');
  w.addBiEdge('A', 'B', 1);
  w.addBiEdge('A', 'C', 2);
  w.addBiEdge('A', 'E', 2);
  w.addBiEdge('A', 'D', 2);
  w.addBiEdge('D', 'E', 1);
  w.addBiEdge('A', 'F', 1, Edge.itemRequired(SimpleItem.redKey));
  return w.node('A');
}

World createSimpleWorld([int seed]) {
  final World world = World(buildSimpleMap);
  world.distributeItems(SimpleItemPool(), seed);
  world.winCondition = (Player player) => player.hasItem(SimpleItem.goal);
  return world;
}
