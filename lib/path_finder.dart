import 'package:a_star/a_star.dart' as a_star;
import 'graph.dart';

class AStarNode extends a_star.Node {
  AStarNode(this.node);
  final Node node;
}

class AStarGraph implements a_star.Graph<AStarNode> {
  AStarGraph(World world)
      : _nodesByName = Map<String, AStarNode>.fromIterable(
          world.nodes,
          key: (dynamic n) => n.name,
          value: (dynamic n) => AStarNode(n),
        );

  final Map<String, AStarNode> _nodesByName;

  AStarNode wrapNode(Node node) => _nodesByName[node.name];
  Node unwrapNode(AStarNode node) => node.node;

  @override
  Iterable<AStarNode> get allNodes => _nodesByName.values;

  @override
  int getDistance(AStarNode a, AStarNode b) => a.node.edgeTo(b.node)?.cost;

  @override
  int getHeuristicDistance(AStarNode tile, AStarNode goal) {
    return getDistance(tile, goal) ?? 0;
    // if h(n) is 0 then  A* turns into Dijkstra’s Algorithm, and is
    // guaranteed to find a shortest path (slowly).
  }

  @override
  Iterable<AStarNode> getNeighboursOf(AStarNode node) =>
      node.node.neighbors.map(wrapNode);
}

/// Hides the existance of AStar from the rest of this.
class PathFinder {
  PathFinder(World world) {
    _graph = AStarGraph(world);
    _aStar = a_star.AStar<AStarNode>(_graph);
  }
  AStarGraph _graph;
  a_star.AStar<AStarNode> _aStar;

  AStarNode wrapNode(Node node) => _graph.wrapNode(node);
  Node unwrapNode(AStarNode node) => _graph.unwrapNode(node);

  Iterable<Node> findPath(Node start, Node end) =>
      _aStar.findPathSync(wrapNode(start), wrapNode(end)).map(unwrapNode);
}
