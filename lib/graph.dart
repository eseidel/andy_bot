import 'dart:math';
import 'path_finder.dart';

// TODO: Export only the used classes.
export 'path_finder.dart';

class Inventory {
  Set<Item> items = <Item>{};
}

abstract class Item {
  int get id;
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

  MeasuredPath findPathTo(Node goal) => world.findPath(location, goal);

  Set<Node> reachableNodes() => world.reachableNodes(this);
}

class Node {
  Node(this.name, {this.item, this.id}) {
    // Assume constructor-specified items default to visible.
    itemIsVisible = item != null;
  }

  int id;
  final String name;
  List<Edge> _edges = <Edge>[];
  List<Node> _allNeighborsCache;
  // TODO: Rename to make visibility more obvious.
  Item item;
  bool itemIsVisible = false;

  List<Edge> get edges => _edges;

  Item get visibleItem => itemIsVisible ? item : null;

  void addEdge(Edge edge) {
    _allNeighborsCache = null;
    _edges.add(edge);
  }

  @override
  String toString() => name;

  bool get hasItem => item != null;

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

class ItemGate {
  ItemGate(Item item) : requiredItems = <Item>[item];

  List<Item> requiredItems;

  bool canPass(Player player) =>
      requiredItems.every((Item item) => player.hasItem(item));
}

class Edge {
  Edge(this.start, this.end, [this.cost = 0, this.gate]);
  final Node start;
  final Node end;
  final int cost;
  final ItemGate gate;

  static CanPass itemRequired(Item item) {
    return (Player player) => player.hasItem(item);
  }

  bool canPass(Player player) => gate == null || gate.canPass(player);

  @override
  String toString() => 'Edge($cost) to $end';
}

T pickOne<T>(Random random, List<T> list) {
  return list[random.nextInt(list.length)];
}

abstract class ItemPool {
  List<Item> get requiredItems;
  Iterable<Item> generateFillerItems(Random random, int count);

  List<Item> shuffledItems(Random random, int count) {
    final List<Item> items = requiredItems;
    final int fillCount = count - items.length;
    if (fillCount < 0)
      throw ArgumentError('Not enough slots for required items.');
    items.addAll(generateFillerItems(random, fillCount));
    items.shuffle(random);
    return items;
  }
}

typedef BuildMap = Node Function(World world);

typedef WinCondition = bool Function(Player player);

class World {
  World(BuildMap buildMap) {
    final Node startLocation = buildMap(this);
    player = Player(this, startLocation);
    pathFinder = PathFinder(this);
  }

  Map<String, Node> nodeByName = <String, Node>{};
  Player player;
  PathFinder pathFinder;
  WinCondition winCondition;
  // all-pairs-shortest-path can be faster if nodes have int ids.
  int _nextNodeId = 0;

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
    nodeByName[name] = Node(name, item: item, id: _nextNodeId++);
  }

  void addBiEdge(String aName, String bName, int cost, [ItemGate gate]) {
    final Node a = node(aName);
    final Node b = node(bName);
    a.addEdge(Edge(a, b, cost, gate));
    b.addEdge(Edge(b, a, cost, gate));
  }
}
