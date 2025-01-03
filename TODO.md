//
//  TODO.md
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 17.11.2024.
//

# TODOs
- Wording
  - check: https://www.merriam-webster.com/thesaurus/top
  - check: https://wikidiff.com
  
## BUG FIXES
- FIX contact graph: fix at, by
- by bidirectional
- FIXME: touching vs meeting at edge, check overlap < maxgap
- FIXME: infront behind not correct!!!!
- check FIXME
- top, topleft?, top left-hand corner/sector?
- bottom, base
- sort relations
- match: under over to below above
- match to synonyms??
- .aligned: front aligned, only same angle?, frontaligned, backaligned, sidealigned?
- inside gap? center or ?
- check for missing terms in SpatialTerms
- gap calculation? Euclidean Signed Distance Function (ESDF)?
- meeting: inverse not working?
- 

## TODO
    
- leftmost, 
- Dynamic Vicinity and Adjacency
- confidence on relations?
- validate succeeded
- is fitting into, exceeding
- is facing towards
- is closest to, nearest to,
- furthest away from, farthest, remotest, outermost
- Nr3D dataset: sample sentences https://referit3d.github.io/benchmarks.html
- topological, directional, and distance relations
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
- adjacency  (Nachbarschaft)
  - voronoi graph??
- Dynamic Vicinity and Adjacency Checking
  - change SpatialAdjustment dynamically --> use in spatial rule engine demo
  - step-wise relaxing of border conditions when pipeline not successful
- Euclidean Signed Distance Function (ESDF) 
- room segmentation: walls
- geography
  - geodetic: north, ...
  - altitude: ?
  - lat/long?
- Confidence
- world depedent/referential: south, north, ...
- object depedent/referential
- observer depedent/ referential: seen left
- is fitting into
- try!! catch?
- chained spatial relations
  - secondleft, thirdleft, forthleft, fifthleft
  - secondleft, secondright, secondabove, secondbelow, secondahead, secondbehind
  - mostleft, ...
  - circularity: circle relations? 
    - circularleft?

- log(): generate Markdown mermaid graph
- visible, focused: as attribute, also as relation?
- opening
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
  
- TODO: Testing: shifted, rotated
- ARchi Composer: show bbox of spatial objects, reasoning editor

## Predicate

### Spatial Relation Attributes
- gap
- angle

## Relation

- enhance Testing

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

## Spatial Query
- get inspiration: https://github.com/jsonquerylang/jsonquery
- Function: filter(object conditions), pick(relation conditions), sort(object attribute, direction)
  - filter(width > 0.5 AND height < 2.4)
  - pick(ahead AND smaller)
  - pick(leftside(gap < 0.1 AND yaw < 5.0))
  - sort(width)
  - sort(height <)
- Input: [SpatialObject]
- Output: [SpatialObject]
- Pipe: |
- Text query (will be parsed into functions and expressions to be evaluated)
- pick2x(), pick3x(), pickNx()
  
filter(visible AND lifespan < 2.5)
| pick(near AND (left OR right))
| sort(volume)

filter(id == '1234')
| pick(near AND (left OR right))
| filter(volume > 0.5)
| sort(volume >)
| log()

## Object Inference
- create conceptual objects
- wall by wall AND wall on floor : corner 
- user : tangibleArea 
- zone between ?

## Reasoning
- Graph reasoning over saptial relations
- Parse and translate query
  - using functions?
  - currentState
    - input
    - output
  
filter(visible AND lifespan < 2.5) --> filter("visible == true AND lifespan < 2.5")
pick(near AND (left OR right)) --> pick("near AND (left OR right)")

## Tests
- ...



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


filter(visible AND volume > 0.5)
| deduce(relation categories) // optional setup to specify/restrict relations to be deduced
| pick(near AND (left OR right))
| sort(age)
| log(left right)


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

Open-Source Repo
- on github
- various, language-specific versions
  - SRswift
  - SRpy
  - SRjs
  - SRunity / SRc#
- Generic docu
- Demo cases

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
- 


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

### Topology

Adjacency (Nachbarschaft): 
- left, right, ...

Connectivity : Verbindung
- in : overlapping?
- ? : crossing
- by : touching
- at : meeting

Orientation
- parallel, orthogonal

Directional
- sector? of center?

Visibility
- seenleft, seenright

Proximity
- near, close, far, leftside, ...

Topology
- inside, contains, disjoint

Comparativity --> better with sort?
- larger, longer


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
