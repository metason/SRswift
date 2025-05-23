# SRswift: Spatial Reasoner in Swift

> _A flexible 3D Spatial Reasoning library for iOS, macOS, and visionOS_

## Features

The SRswift library supports the following operations of the [__Spatial Reasoner Syntax__](https://github.com/metason/SpatialReasoner#syntax-of-spatial-inference-pipeline) to specify a spatial inference pipeline.

- [x] __adjust__: optional setup to adjust nearby, sector, and max deviation settings
- [x] __deduce__: optional setup to specify relation categories to be deduced
- [x] __filter__: filter objects by matching spatial attributes
- [x] __isa__: filter objects that belong to a type in a class hierarchy (taxonomy)
- [x] __pick__: pick objects along their spatial relations
- [x] __select__: select objects having spatial relations with others
- [x] __sort__: sort objects by metric attributes or by spatial relations
- [x] __slice__: choose a subsection of spatial objects 
- [x] __calc__: calculate global variables in fact base
- [x] __map__: calculate values of object attributes
- [x] __produce__: create new spatial objects driven by their relations
- [x] __backtrace__: output spatial objects of operation some steps back in pipeline  
- [x] __reload__: reload and output all spatial objects of fact base
- [x] __halt__: stop processing the inference pipeline (for debug purposes)
- [x] __log__: log the current status of the inference pipeline


## Getting Started

### Documentation

See [__Docu on SpatialReasoner__](https://github.com/metason/SpatialReasoner) framework in separate repository.

### Building and Integrating

Use XCode package manager to import the SRswift library using the link to this repository:
https://github.com/metason/SRswift.

## Tests

SRswift includes extensive test cases. They include some `expect()` conditions but also `log(base 3D)` pipeleine operations for visual approval. Some test cases (named `*Vis`) are "misused" to generate visualizations that are included in the [documentation of SpatialReasoner](https://github.com/metason/SpatialReasoner).

## License

Released under the [Creative Commons CC0 License](LICENSE).

## Contact

Philipp Ackermann, philipp@metason.net
