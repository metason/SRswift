//
//  TODO.md
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 17.11.2024.
//

# TODOs
  
## BUG FIXES

- check delta calc
- delta calculation? Euclidean Signed Distance Function (ESDF)?
- delta of .by and .at (min distance or overlap?)
- check FIXME: and TODO:
- top, topleft?, top left-hand corner/sector?
- substitute (not found predicates)
    - match to synonyms
    - NOT predicate ?? for antonyms
- aligned: front aligned, only same angle?, frontaligned, backaligned, sidealigned?
- check for missing terms in SpatialTerms
- meeting: inverse?

## produce
- aggregate / group = bbox over all, aligned with largest
- duplicate / copy = copy of each
- *side = inbetween bbox (minimal)
- *aligned = meeting bbox (minimal)
- orthogonal = spanned area
- opposite = inbetween bbox (minimal)
- touching / by = edge bbox
- meeting / at = plane bbox
- on = plane bbox
- sector = sector bbox of each

## TODO

- error handling via inference: error messages
- each() oder all(): reset input to all objects
- strings in pipeline: handle no quotes as well as ' and "
- leftmost, 
- Dynamic Vicinity and Adjacency
- confidence on relations?
- validate succeeded
- is fitting into, exceeding
- is facing towards
- is closest to, nearest to, --> use sort()
- furthest away from, farthest, remotest, outermost
- Nr3D dataset: sample sentences https://referit3d.github.io/benchmarks.html
- multi-stage spatial reasoning, multi-stage relations
- Spatial reasoning, involves understanding and navigating the relationships among objects in space
- limitations in representing the complexity found in real-world spatial reasoning
- Objects are described and distinguished using a combination of label, look/color, size, and shape
    - plus the spatial characteristics: global world-oriented, local  object-related, intra-object-related

- Vicinity (Nähe)
  - center - position - perimeter
  - bbox - sectors - edges - corners?
  - sectors
  - sides
- adjacency (Nachbarschaft)
  - voronoi graph??
- Dynamic Vicinity and Adjacency Checking
  - change SpatialAdjustment dynamically --> use in spatial rule engine demo
  - step-wise relaxing of border conditions when pipeline not successful
- Euclidean Signed Distance Function (ESDF) 
- room segmentation: walls
- geography
  - geodetic: north, ...
  - altitude: ?
- is fitting into
- try!! catch for Predicate / Expression
- chained spatial relations --> use sort()
  - secondleft, thirdleft, forthleft, fifthleft
  - secondleft, secondright, secondabove, secondbelow, secondahead, secondbehind
  - mostleft, ...
  - circularity: circle relations? 
    - circularleft?

- visible, focused: as attribute, also as relation?
- has opening
  - inside // e.g. wall
  - top // crate, open-topped box
  - front // compartment, front-open box
  - none // closed box
  - closablefront, closabletop...
  - opentop, openfront, openside

- operable
  - movable
  - openable
  - slidable
  - portable
  - liftable
  - rotatable
  - tangible?? user-dep.
  
- ARchi Composer: show bbox of spatial objects, reasoning editor


## Object

### Spatial Attributes

User-related
- visible
- focused
- tangible // can be grabbed (by hand)

## Relation Inference (Query)

- Inference of spatial conditions
- Range Query: objects within a certain radius or range
  - euclidean distance (radius)
- Region/Sector Query
  - window/sector
- Direction-constrained Query
- Angle-constrained Query

Check:
- https://github.com/slazyk/SINQ
- https://github.com/kishikawakatsumi/Kuery

## Object Inference
- produce()
- create conceptual objects
- wall by wall AND wall on floor : corner 
- user : tangibleArea 
- zone between ?


## Spatial Inference TODOs

Spatial Reasoner
- Update and match objects in fact base
- Derive spatial attributes  
- Deduce spatial relations
- Run pipeline
- derive: object attributes (done automatically)
- deduce: type of relations
- produce: new spatial objects (conceptual)
- (halt: stop pipeline and fail)


Spatial inference operations: In a 3D scenery find all subjects matching a given spatial relationship with a reference object (search object).
Spatial Reasoning Language: simple text specification of a spatial inference pipeline 
Inference operation: filter, pick, sort, analyse, validate, log, map?
- input - process - output
pipeline: chain of inference ops
Spatial relations: subject - predictae - object
Derive spatial attributes and object-relations 
Inference of spatial conditions

## Long-term Topics

Spatio-temporal Reasoning
- keep time-stamped snapshots
- calculate trends on confidence: pose, dimension, label/class, ...
- estimate movements

Voice-based Interaction and Language Models
- Speech recognition to interact with spatial scene
- TTS 
- use of LLM
- get rid of hand controllers 
- add actionable:ObjectHandling to SpatialObject
- Instructions / Education case using speech
- Track behavior in space, xAPI

Route Finding
- Voronoi-based Route Graph


## Motivation

Cardinal Direction Relations in 3D --> sectors
higher-level spatial concepts (e.g., objects, agents, places, rooms), not point clouds or polygon meshes
Agents, robots and autonomous systems
High-level representations are required to understand and execute instructions from humans (e.g., bring me the cup of tea I left on the dining room table)
also enable efficient planning (e.g., by allowing planning over compact abstractions rather than dense low-level geometry)
reasoning in real-time to support just-in-time decision-making
mostly concerned with objects and their relations while disregarding the top layers
Part-of assembly graph versus "flat" 3D scene graphs
navigation, capturing moving entities in the environment
metric-semantic mapping
hierarchical map
metric and topological representations in 2D
compute a Voronoi graph from a 2D occupancy grid
project 3D point clouds to 2D maps
Hierarchical 3D Representation: grouping of inside/parts as layers in 3D with relation lines
- calculate aggregation/group bbox


# Spatial Terms (Brain-Storming Level)

## Spatial metric attributes

Base values 
- location
  - position
  - center
- dimensions
  - width
  - height
  - depth
- orientation
  - angle
  
Derived values
- volume
- ...

## Spatial boolean attributes
- immobile
- moving
- equilateral
- long
- thin
- visible
- focused
- tangible? reach radius 0.7+

## Spatial comparison values

- volume: smaller - larger/bigger
- area: smaller - larger/bigger
- length: shorter - longer
- width/depth: taller - wider (narrower?)
- if both are long: thinner, thicker
- height: lower - higher ???
- 

## Spatial relations

Connectivity : Verbindung
- in : container
- by : touching
- at : meeting
- on : ontop


| Category | Spatial Relations |
| --- | -----|
| Adjacency | adjacent to, alongside, at the side of, at the right side of, at the left side of, attached to, at the back of, ahead of, against, at the edge of |
| Directional | off, past, toward, down, deep down∗, up∗, away from, along, around, from∗, into, to, across, across from, through, down from |
| Orientation | facing, facing away from, parallel to, perpendicular to |
| Projective | on top of, beneath, beside, behind, left of, right of, under, in front of, below, above, over, in the middle of |
| Proximity | by, close to, near, far from, far away from |
| Topological | connected to, detached from, has as a part, part of, contains, within, at, on, in, with, surrounding, among, consists of, out of, between, inside, outside, touching, meeting |
| Unallocated | beyond, next to, opposite to, among, enclosed by |


## Adverbs of Place

Above
Across = opposite?
Ahead
Along
Apart from
Around
Away
Back
Behind
Below
Beside
Between --> ternary relation!!
Close to
Everywhere
Far
Here
In
Inside
Near
Next to
Nowhere
Off
On
Onto
Outside
Over
Past
Somewhere
There
Through
Toward
Under
Underneath
Up
Within

??????:
Vertical
Horizontal
Beyond
Against
Together
Separate
Join
Apart from, disjoint??
Between
Among
Middle
Center
Across
Diagonal
Reverse
Upside down


## Adjectives in Space


## UNCLEAR
None
More
Less
Same
Equal

TODO:
- Shape: Rectangular, Triangular?
- in front of, at the back of, at rear of,
- above, beneath, below,
- over, under
- under, over, on, on top of,
- in the middle of
- at the back of, at the rear of
- next to, close to, near by,
- in, inside
- at the side of, beside
- alongside
- by, nearby
- far from, far away from
- attached to, connected to
- beside
- at the egde of
- containing, consists of,
- inside, inside of, part of,
- outside
- across from, opposite to
- parallel to
- perpendicular to
- surrounding
- enclosed by
- adjacent to
- A is on B
- facing = facing towards, NEG: facing away from
- across
- between
- beyond
- eastwards
- far
- northwards
- toward
- around

## Denominators

- Wording
  - check: https://www.merriam-webster.com/thesaurus/top
  - check: https://wikidiff.com
