//
//  TODO.md
//  SpatialReasoning
//
//  Created by Philipp Ackermann on 17.11.2024.
//

# TODOs
  
## BUG FIXES

- missing relation: book on table in Test
- crashes in predicate eval when not well formulated! 
- check FIXME:

## Clarify

- expose x/y/z of position as dictionary keys? cx/cy/cz? w/h/d?
- README of Spatial Reasoner: add C# example
- SpatialTerms: concept for language translation
- Visibility predicates: covering, (partially) hiding
- deduce sub topologies separately?
- usage of NOT (or !) --> test cases
- Euclidean Signed Distance Function (ESDF)
  - interpretation of negative values
  - min distance, neg. on overlap?
  - check delta calc --> test cases

## GENERAL IDEAS
  
- improve assertions in test cases
- substitute not found predicates
    - match to synonyms
    - NOT predicate for antonyms
- strings in pipeline: handle no quotes as well as ' and "
- confidence on relations
- enhance produce()
  - *side = inbetween bbox (minimal)?
  - *aligned = meeting bbox (minimal)?
  - orthogonal = spanned area?
  - opposite = inbetween bbox (minimal)
  - zone?
- Dynamic Vicinity and Adjacency Checking
  - change SpatialAdjustment dynamically --> use in spatial rule engine demo
  - step-wise relaxing of border conditions when pipeline not successful
- adjacency voronoi graph (Nachbarschaft)
- Spatial Onthology Editor (standalone from ARchi Composer)
  - File format for exchange: meta data (author, context), ruleset
  - ARchi Composer: reasoning editor, show bbox of spatial objects 
  - Language translator for SpatialTerms and SpatialTaxonomy

## Predicates

- is fitting into, is exceeding
- is facing / facing towards
- is focusing // gazing; +/- maxAngleDelta
- Nr3D dataset: sample sentences https://referit3d.github.io/benchmarks.html
- geography /geodetic: altitude: ?
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

## Long-term Topics / Future Use Cases

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

