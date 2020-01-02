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
      w.addBiEdge('B', 'C', 3, Edge.itemRequired(ItemType.redKey));
      return w.node('A');
    });
    Node node(String name) => world.node(name);
    world.player.location = node('A');
    final Set<Node> reachable = world.reachableNodes();
    expect(reachable.length, equals(2));
    expect(reachable, containsAll(<Node>[node('A'), node('B')]));
    expect(world.findPath(node('A'), node('C')), isNull);

    world.player.addItem(ItemType.redKey);
    final Set<Node> reachableWithKey = world.reachableNodes();
    expect(reachableWithKey.length, equals(3));
    expect(
        reachableWithKey, containsAll(<Node>[node('A'), node('B'), node('C')]));
    expect(world.findPath(node('A'), node('C')).cost, equals(5));
  });
}
