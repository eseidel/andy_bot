import 'package:test/test.dart';
import 'package:andy_bot/graph.dart';

void main() {
  test('Path measuring', () {
    final World world = World((World w) {
      w.addNode('A');
      w.addNode('B');
      w.addNode('C');
      w.addNode('D');
      w.addBiEdge('A', 'B', 2);
      w.addBiEdge('B', 'C', 3);
      return w.node('A');
    });
    Node node(String name) => world.node(name);

    expect(world.findPath(node('A'), node('B')).cost, equals(2));
    expect(world.findPath(node('A'), node('C')).cost, equals(5));
    expect(world.findPath(node('A'), node('D')), isNull);
  });
  test('Gates', () {
    final World world = World((World w) {
      w.addNode('A');
      w.addNode('B');
      w.addNode('C');
      w.addBiEdge('A', 'B', 2);
      w.addBiEdge('B', 'C', 3, Edge.itemRequired(Item.redKey));
      return w.node('A');
    });
    final Player player = world.player;
    Node node(String name) => world.node(name);

    final Set<Node> reachable = player.reachableNodes();
    expect(reachable.length, equals(2));
    expect(reachable, containsAll(<Node>[node('A'), node('B')]));
    expect(world.findPath(node('A'), node('C')), isNull);

    player.addItem(Item.redKey);
    final Set<Node> reachableWithKey = player.reachableNodes();
    expect(reachableWithKey.length, equals(3));
    expect(
        reachableWithKey, containsAll(<Node>[node('A'), node('B'), node('C')]));
    expect(world.findPath(node('A'), node('C')).cost, equals(5));
  });
  test('Movement', () {
    final World world = World((World w) {
      w.addNode('A', Item.goal);
      w.addNode('B', Item.redKey);
      w.addBiEdge('A', 'B', 2);
      return w.node('A');
    });
    final Player player = world.player;
    Node node(String name) => world.node(name);

    expect(player.traveledPath.cost, equals(0));
    expect(player.hasItem(Item.goal), isTrue);

    player.moveTo(node('B'));
    expect(player.traveledPath.cost, equals(2));
    expect(player.hasItem(Item.redKey), isTrue);
    expect(node('B').item, isNull);

    player.moveTo(node('A'));
    expect(player.traveledPath.cost, equals(4));
  });
  test('Items', () {
    final World world = World((World w) {
      w.addNode('A');
      w.addNode('B');
      w.addNode('C');
      w.addNode('D');
      return w.node('A');
    });
    expect(world.nodes.map((Node n) => n.item),
        equals(List<Item>.filled(4, null)));
    // Should this be a test-specific fixure instead of SimpleItemPool?
    world.distributeItems(SimpleItemPool(), 0);
    expect(world.nodes.map((Node n) => n.item),
        unorderedEquals(<Item>[Item.redKey, Item.goal, Item.junk, Item.junk]));
  });
}
