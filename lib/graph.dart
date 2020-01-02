import 'path_finder.dart';

// TODO: This could be less.
export 'path_finder.dart';

class Inventory {}

class Player {
  Player(this.location);

  Node location;
  Inventory inventory;
}

class Node {
  Node(this.name);

  final String name;
  List<Edge> _edges = <Edge>[];
  List<Node> _neighborsCache;

  void addEdge(Edge edge) {
    _neighborsCache = null;
    _edges.add(edge);
  }

  Edge edgeTo(Node end) =>
      _edges.firstWhere((Edge e) => e.end == end, orElse: () => null);

  Iterable<Node> get neighbors =>
      _neighborsCache ??= _edges.map((Edge e) => e.end).toList();
}

typedef CanPass = bool Function(Player player);

class Edge {
  Edge(this.end, [this.cost = 0, this.canPass]);
  final int cost;
  final CanPass canPass;
  final Node end;
}

enum ItemType {
  BlueKey, // Goal
  RedKey,
  Junk,
}

class Item {
  Item(this.type);
  ItemType type;
}

class ItemPool {
  List<Item> requiredItems = <Item>[
    Item(ItemType.BlueKey),
    Item(ItemType.RedKey),
  ];
}

typedef InitalizeMap = void Function(World world);

void initSimpleMap(World w) {
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
  w.addBiEdge('A', 'F', 1, ItemType.RedKey);
}

class World {
  World(InitalizeMap initMap) {
    initMap(this);
    player = Player(node('A'));
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

  void addNode(String name) {
    assert(nodeByName[name] == null);
    nodeByName[name] = Node(name);
  }

  void addBiEdge(String startName, String endName, int cost, [ItemType key]) {
    node(startName).addEdge(Edge(node(endName), cost));
    node(endName).addEdge(Edge(node(startName), cost));
  }
}

// https://docs.google.com/drawings/d/1YJdXb9xBr0QRxe7666wHTwRLNNWSxriLlLl-JbAkqUg/edit?folder=0AFC4tS7Ao1fIUk9PVA
