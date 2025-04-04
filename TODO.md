//
//  TODO.md
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 17.11.2024.
//

# TODOs
  
## BUG FIXES

- check FIXME:

## Clarify

- README of Spatial Reasoner: add C# example
- SpatialTerms: concept for language translation
- Predicate: covering, (partially) hiding


## SUBITO TODO (before launch)

- check TODO:
- improve assertions in test cases
- improve Spatial Terms
- enhance README: Tests
- finalize produce()
  - on, at, sector
- check on topology == false
  - sub topologies on/off?
- delta calculation? Euclidean Signed Distance Function (ESDF)
  - check delta calc --> test cases
  - min distance, neg. on overlap?
- usage of NOT (or !) --> test cases
- remove WARNING:

## GENERAL IDEAS
  
- substitute not found predicates
    - match to synonyms
    - NOT predicate for antonyms
- strings in pipeline: handle no quotes as well as ' and "
- confidence on relations
- enhance produce()
  - sectors?
  - *side = inbetween bbox (minimal)?
  - *aligned = meeting bbox (minimal)?
  - orthogonal = spanned area?
  - opposite = inbetween bbox (minimal)
  - zone?
- Dynamic Vicinity and Adjacency Checking
  - change SpatialAdjustment dynamically --> use in spatial rule engine demo
  - step-wise relaxing of border conditions when pipeline not successful
- adjacency voronoi graph (Nachbarschaft)
- Spatial Onthology Editor
  - File format for exchange: meta data (author, context), ruleset
  - ARchi Composer: reasoning editor, show bbox of spatial objects 
  - Language translator for SpatialTerms and SpatialTaxonomy


## Predicates

- is fitting into, is exceeding
- is facing / facing towards
- is focusing // gazing; +/- maxAngleDelta
- is closest to, nearest to, --> use sort()
  - furthest away from, farthest, remotest, outermost --> use sort()
- Nr3D dataset: sample sentences https://referit3d.github.io/benchmarks.html
- geography /geodetic: altitude: ?
- chained spatial relations --> use sort()
  - secondleft, thirdleft, forthleft, fifthleft
  - secondleft, secondright, secondabove, secondbelow, secondahead, secondbehind
  - mostleft, ...
  - circularity: circle relations? 
    - circularleft?
- visible, focused: as attribute, also as relation?


## Object Attributes

- has opening
  - inside // e.g. wall
  - top // crate, open-topped box
  - front // compartment, front-open box
  - none // closed box
  - closablefront, closabletop...
  - opentop, openfront, openside
  
- shape: Rectangular, Triangular?

- User-related
  - visible
  - focused
  - tangible ? // can be grabbed (by hand)
- operable
  - movable
  - openable
  - slidable
  - portable
  - liftable
  - rotatable
  - tangible?? user-dep.


## Long-term Topics / Use Cases

Spatio-temporal Reasoning
- keep time-stamped snapshots
- calculate trends on confidence: pose, dimension, label/class, ...
- estimate movements

Voice-based Interaction and Language Models
- Speech recognition to interact with spatial scene
- TTS 
- use of LLM
- get rid of hand controllers 
- add actionable: ObjectHandling to SpatialObject
- Instructions / Education case using speech
- Track behavior in space, xAPI

Route Finding
- Voronoi-based Route Graph

