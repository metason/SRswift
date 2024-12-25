# Spatial Relations

## Topology

### Adjacency

| Predicate | Relation  | Specification | Visual Sample |
| --- | ---- | ---- | -------- | 
| `left` | subj is __left__ of obj | <ul><li>center of subject is in `.l` sector</li><li>may overlap</li><li>no distance condition</li><li>delta = center distance</li></ul>  | ![left](images/left.png) |
| `right` | subj is __right__ of obj | <ul><li>center of subject is in `.r` sector</li><li>may overlap</li><li>no distance condition</li><li>delta = center distance</li></ul> | ![right](images/right.png) |
| `ahead` | subj is __ahead__ of obj | <ul><li>center of subject is in `.a` sector</li><li>may overlap</li><li>no distance condition</li><li>delta = center distance</li></ul> |  ![ahead](images/ahead.png) |
| `behind` | subj is __behind__ obj | <ul><li>center of subject is in `.b` sector</li><li>may overlap</li><li>no distance condition</li><li>delta = center distance</li></ul> | ![behind](images/behind.png) |
| `above`<br>`over` | subj is __above__ obj<br>subj is __over__ obj |<ul><li>center of subject is in `.o` sector</li><li>may overlap</li><li>no distance condition</li><li>delta = center distance</li></ul> |  ![above](images/above.png) |
| `below`<br>`under` | subj is __below__ obj<br>subj is __under__ obj | <ul><li>center of subject is in `.u` sector</li><li>may overlap</li><li>no distance condition</li><li>delta = center distance</li></ul> | ![below](images/below.png) |

### Proximity


| Predicate | Relation  | Specification | Visual Sample |
| --- | ---- | ---- | -------- | 
| `near` | subj is __near__ by obj | <ul><li>center of subject is not inside / not in `.i` sector</li><li>center distance < nearby condition of adjustment</li><li>delta = center distance</li></ul> |  ![near](images/near.png) |
| `leftside` | subj is at __leftside__ of obj | <ul><li>center of subject is in `.l` sector</li><li>is near</li><li>is not overlapping</li><li>delta = min distance</li></ul> |  ![leftside](images/leftside.png) |
| `rightside` | subj is at __rightside__ of obj | <ul><li>center of subject is in `.r` sector</li><li>is near</li><li>is not overlapping</li><li>delta = min distance</li></ul> | ![rightside](images/rightside.png) |
| `frontside` | subj is at __frontside__ of obj | <ul><li>center of subject is in `.a` sector</li><li>is near</li><li>is not overlapping</li><li>delta = min distance</li></ul>  | ![frontside](images/frontside.png) |
| `backside` | subj is at __backside__ of obj | <ul><li>center of subject is in `.b` sector</li><li>is near</li><li>is not overlapping</li><li>delta = min distance</li></ul> | ![backside](images/backside.png) |
| `upperside` | subj is at __upperside__ of obj | <ul><li>center of subject is in `.o` sector</li><li>is near</li><li>is not overlapping</li><li>delta = min distance</li></ul>  | ![upperside](images/upperside.png) |
| `lowerside` | subj is at __lowerside__ of obj | <ul><li>center of subject is in `.u` sector</li><li>is near</li><li>is not overlapping</li><li>delta = min distance</li></ul> | ![lowerside](images/lowerside.png) |
| `ontop` | subj is __ontop__ of obj | <ul><li>center of subject is in `.o` sector</li><li>is near</li><li>is not overlapping</li><li>min distance < max gap</li><li>delta = min distance</li></ul>  | ![ontop](images/ontop.png) |
| `beneath` | subj is __beneath__ of obj | <ul><li>center of subject is in `.u` sector</li><li>is near</li><li>is not overlapping</li><li>min distance < max gap</li><li>delta = min distance</li></ul> | ![beneath](images/beneath.png) |


## Connectivity
 
| Predicate | Relation  | Specification | Visual Sample |
| --- | ---- | ---- | -------- | 
| `on` | subj is __on__ obj | <ul><li>is near</li><li>is on top</li><li>min distance < max gap</li><li>delta = min distance</li></ul>  | ![on](images/on.png) |
| `at` | subj is __at__ obj | <ul><li>is beside</li><li>is meeting</li><li>min distance < max gap</li><li>delta = min distance</li></ul> | ![at](images/at.png) |
| `by` | subj is __by__ obj | <ul><li>is touching</li><li>min distance < max gap</li></ul> |  ![by](images/by.png) |
| `in` | subj is __in__ obj | <ul><li>is inside</li></ul> | ![in](images/in.png) |

## Directionality
