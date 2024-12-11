//
//  TODO.md
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 17.11.2024.
//


GITHUB
- wo? Metason?
- wann?
- Spatial Reasoning Kit / Lib?
  - SRkit: Spatial Reasoning Library
  - Spatial Reasoning Language
  - Spatial Predicates and Relations
- SR: Spatial Reasoning (Libs)
  - SRswift
  - SRpy
  - SRunity
  - SRjs
- Wording
  - check: https://www.merriam-webster.com/thesaurus/top
  - check: https://wikidiff.com
  
  
## BUG FIXES
- meeting: inverse not working!
- FIXME: touching vs meeting at edge, check overlap < max.gap
- 

## TODO

Spatial Reasoning Language: text
- validate succeeded
- is fitting into, exceeding
- Is facing towards
- Is closest to, nearest to,
- furthest away from, farthest, remotest, outermost
- Nr3D dataset: sample sentences https://referit3d.github.io/benchmarks.html
- Perspective vs projective relations, view depedent
- topological, directional, and distance relations
- multi-Stage spatial reasoning, multi-stage relations
- Spatial reasoning, involves understanding and navigating the relationships among objects in space
- limitations in representing the complexity found in real-world spatial reasoning
- Objects are described and distinguished using a combination of label, look/color, size, and shape
    - plus the spatial characteristics: global world-oriented, local  object-related, intra relation-related

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
  - sort(height ASC)
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
| sort(volume DESC)
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
