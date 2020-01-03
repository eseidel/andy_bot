import 'path_finder.dart';

// TODO: This could be less.
export 'path_finder.dart';

class Inventory {
  Set<Item> items = <Item>{};
}

class Player {
  Player(this.world, Node location) {
    traveledPath = MeasuredPath(<Node>[location]);
    _takeItem(location);
  }

  void addItem(Item item) => inventory.items.add(item);
  bool hasItem(Item item) => inventory.items.contains(item);

  World world;
  MeasuredPath traveledPath;
  Node get location => traveledPath.nodes.last;
  Inventory inventory = Inventory();

  void _takeItem(Node goal) {
    if (goal.item != null) {
      addItem(goal.item);
    }
    goal.item = null;
  }

  void moveTo(Node goal) {
    final MeasuredPath path = world.findPath(location, goal);
    if (path == null) {
      throw ArgumentError('goal not reachable');
    }
    traveledPath += path;
    _takeItem(goal);
  }
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
  blueKey, // Goal
  redKey,
  junk,
}

class ItemPool {
  List<Item> requiredItems = <Item>[
    Item.blueKey,
    Item.redKey,
  ];
}

typedef InitalizeMap = Node Function(World world);

Node initSimpleMap(World w) {
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
  World(InitalizeMap initMap) {
    final Node startLocation = initMap(this);
    player = Player(this, startLocation);
    pathFinder = PathFinder(this);
  }

  factory World.simple() {
    return World(initSimpleMap);
  }

  Map<String, Node> nodeByName = <String, Node>{};
  Player player;
  PathFinder pathFinder;

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

  Set<Node> reachableNodes() {
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
