import 'dart:math';
import 'path_finder.dart';

// TODO: Export only the used classes.
export 'path_finder.dart';

class Inventory {
  Set<Item> items = <Item>{};
}

class Player {
  Player(this.world, Node location) {
    traveledPath = MeasuredPath(<Node>[location]);
    takeItem();
  }

  void addItem(Item item) => inventory.items.add(item);
  bool hasItem(Item item) => inventory.items.contains(item);

  World world;
  MeasuredPath traveledPath;
  Node get location => traveledPath.nodes.last;
  Inventory inventory = Inventory();

  void takeItem() {
    if (location.item != null) {
      addItem(location.item);
    }
    location.item = null;
  }

  void moveTo(Node goal) {
    final MeasuredPath path = world.findPath(location, goal);
    if (path == null) {
      throw ArgumentError('goal not reachable');
    }
    traveledPath += path;
    takeItem();
  }

  Set<Node> reachableNodes() => world.reachableNodes(this);
}

class Node {
  Node(this.name, [this.item]);

  final String name;
  List<Edge> _edges = <Edge>[];
  List<Node> _allNeighborsCache;
  Item item;

  void addEdge(Edge edge) {
    _allNeighborsCache = null;
    _edges.add(edge);
  }

  @override
  String toString() => name;

  Edge edgeTo(Node end) =>
      _edges.firstWhere((Edge e) => e.end == end, orElse: () => null);

  Iterable<Node> get allNeighbors =>
      _allNeighborsCache ??= _edges.map((Edge e) => e.end).toList();

  Iterable<Node> reachableNeighbors(Player player) sync* {
    for (Edge edge in _edges) {
      if (edge.canPass(player)) {
        yield edge.end;
      }
    }
  }
}

typedef CanPass = bool Function(Player player);

class Edge {
  Edge(this.end, [this.cost = 0, this.canPassFunc]);
  final int cost;
  final CanPass canPassFunc;
  final Node end;

  static CanPass itemRequired(Item item) {
    return (Player player) => player.hasItem(item);
  }

  bool canPass(Player player) => canPassFunc == null || canPassFunc(player);

  @override
  String toString() => 'Edge($cost) to $end';
}

enum Item {
  goal,
  redKey,
  junk,
}

abstract class ItemPool {
  List<Item> shuffledItems(Random random, int count);
}

class SimpleItemPool implements ItemPool {
  List<Item> requiredItems = <Item>[
    Item.goal,
    Item.redKey,
  ];

  List<Item> fillItems = <Item>[
    Item.junk,
  ];

  @override
  List<Item> shuffledItems(Random random, int count) {
    final List<Item> items = requiredItems;
    final int fillCount = count - items.length;
    if (fillCount < 0)
      throw ArgumentError('Not enough slots for required items.');
    items.addAll(List<Item>.generate(fillCount, (int _) {
      return fillItems[random.nextInt(fillItems.length)];
    }));
    items.shuffle(random);
    return items;
  }
}

typedef BuildMap = Node Function(World world);

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
  w.addBiEdge('A', 'F', 1, Edge.itemRequired(Item.redKey));
  return w.node('A');
}

class World {
  World(BuildMap buildMap) {
    final Node startLocation = buildMap(this);
    player = Player(this, startLocation);
    pathFinder = PathFinder(this);
  }

  factory World.simple([int seed]) {
    final World world = World(buildSimpleMap);
    world.distributeItems(SimpleItemPool(), seed);
    return world;
  }

  Map<String, Node> nodeByName = <String, Node>{};
  Player player;
  PathFinder pathFinder;

  void distributeItems(ItemPool pool, int seed) {
    final Random random = Random(seed);
    final List<Item> items = pool.shuffledItems(random, nodes.length);
    for (Node node in nodes) {
      node.item = items.removeLast();
    }
  }

  MeasuredPath findPath(Node start, Node end) =>
      pathFinder.findPath(start, end);

  Node node(String name) => nodeByName[name];

  Iterable<Node> get nodes => nodeByName.values;

  static void addReachable(Set<Node> reachable, Node start, Player player) {
    if (reachable.contains(start)) {
      return;
    }
    reachable.add(start);
    for (Node node in start.reachableNeighbors(player))
      addReachable(reachable, node, player);
  }

  Set<Node> reachableNodes(Player player) {
    final Set<Node> reachable = <Node>{};
    addReachable(reachable, player.location, player);
    return reachable;
  }

  void addNode(String name, [Item item]) {
    assert(nodeByName[name] == null);
    nodeByName[name] = Node(name, item);
  }

  void addBiEdge(String startName, String endName, int cost,
      [CanPass canPass]) {
    node(startName).addEdge(Edge(node(endName), cost, canPass));
    node(endName).addEdge(Edge(node(startName), cost, canPass));
  }
}

// https://docs.google.com/drawings/d/1YJdXb9xBr0QRxe7666wHTwRLNNWSxriLlLl-JbAkqUg/edit?folder=0AFC4tS7Ao1fIUk9PVA
