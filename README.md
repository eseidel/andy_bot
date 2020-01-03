# andy_bot
Can a bot alttpr faster than Andy?

There are separate problems here.
1. A tactical problem of how to execute movement around ALTTP.
2. A strategic problem of how to decide where to move.

I'm looking at the second first.

A diagram of the first simplified second problem I'm tackling: https://docs.google.com/drawings/d/1YJdXb9xBr0QRxe7666wHTwRLNNWSxriLlLl-JbAkqUg/edit?folder=0AFC4tS7Ao1fIUk9PVA


TODO
* Need a strategy which is aware of future gate openings.
* Make a slightly more realistic map.
* Add a "restart" edge to all nodes.


Strategy Thoughts
* Use expected value / expected cost of a given route?
* Look a fixed search distance ahead?  Or a search distance until a given EV?
* Re-distribute expected value (and cost?) from unreachable nodes to keys (progression items)?
