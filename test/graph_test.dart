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
    });
    Node node(String name) => world.node(name);
    expect(world.findPath(node('A'), node('B')).cost, equals(2));
    expect(world.findPath(node('A'), node('C')).cost, equals(5));
    expect(world.findPath(node('A'), node('D')), equals(null));
  });
}
