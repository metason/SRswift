//
//  SpatialTaxonomy.swift
//  SRswift
//
//  Created by Philipp Ackermann on 23.03.2025.
//

import Foundation

public class SpatialObjectConcept : Hashable, Identifiable {

    public init(label:String, id:String? = nil, parentId:String? = nil) {
        self.label = label
        if id == nil {
            self.id = label
        } else {
            self.id = id!
        }
        self.parentId = parentId
    }
    
    public var id:String
    public var label:String
    public var comment:String = ""
    public var synonyms:[String]? = nil
    public var parentId:String? = nil
    public var parent:SpatialObjectConcept? = nil
    public var references:[String]? = nil
    public var children:[SpatialObjectConcept]? = nil
    
    public func addChild(_ concept:SpatialObjectConcept) {
        if children == nil {
            children = [concept]
        } else {
            children?.append(concept)
        }
    }
    
    public func addSynonym(_ synonym:String) {
        if synonyms == nil {
            synonyms = [synonym]
        } else {
            synonyms?.append(synonym)
        }
    }
    
    public func addRef(_ ref:String) {
        if references == nil {
            references = [ref]
        } else {
            references?.append(ref)
        }
    }
    
    public func isa(type:String, precise: Bool = true) -> SpatialObjectConcept? {
        let query = type.lowercased()
        if query == label.lowercased() {
            return self
        }
        if synonyms != nil {
            for syn in synonyms!{
                if syn.lowercased() == query {
                    return self
                }
            }
        }
        if parent != nil {
            return parent!.isa(type: query, precise: precise)
        }
        if !precise {
            if label.lowercased().contains(query) {
                return self
            }
            if synonyms != nil {
                for syn in synonyms!{
                    if syn.lowercased().contains(query) {
                        return self
                    }
                }
            }
        }
        return nil
    }
    
    public func asText(level:Int = 0, prefix: String = "- ", indent: String = "  ") -> String {
        var str = String(repeating: indent, count: level)
        str = str + prefix + label
        if synonyms != nil {
            str = str + " (" + synonyms!.joined(separator: ", ") + ")\n"
        } else {
            str = str + "\n"
        }
        if children != nil {
            for child in children! {
                str = str + child.asText(level: level+1, prefix: prefix, indent: indent)
            }
        }
        return str
    }
    
    public static func == (lhs: SpatialObjectConcept, rhs: SpatialObjectConcept) -> Bool {
        lhs.label == rhs.label
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
}

class TaxonomyParser : NSObject, XMLParserDelegate {
    
    var label:String = ""
    var comment:String = ""
    var id:String = ""
    var parentId:String = ""
    var synonyms:[String] = []
    var references:[String] = []
    var currentAttribute:String = ""
    
    func addConcept() {
        if label.count > 0 {
            let concept = SpatialObjectConcept(label: label, id: id, parentId: parentId)
            concept.comment = comment
            if !synonyms.isEmpty {
                concept.synonyms = synonyms
            }
            if !references.isEmpty {
                concept.references = references
            }
            SpatialTaxonomy.concepts.append(concept)
        }
        ///  reset all variables
        label = ""
        comment = ""
        id = ""
        parentId = ""
        synonyms.removeAll()
        references.removeAll()
        currentAttribute = ""
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        //print("Start parsing OWL/RDF document")
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        //print("elName: \(elementName)")
        if (elementName == "owl:Class") {
            /// add
            addConcept()
            for (attr_key, attr_val) in attributeDict {
                //print("Key: \(attr_key), value: \(attr_val)")
                if attr_key == "rdf:about" {
                    id = attr_val
                }
            }
        } else if (elementName == "rdfs:subClassOf") {
            for (attr_key, attr_val) in attributeDict {
                if attr_key == "rdf:resource" {
                    parentId = attr_val
                }
            }
        } else if (elementName == "rdfs:seeAlso") {
            for (attr_key, attr_val) in attributeDict {
                if attr_key == "rdf:resource" {
                    references.append(attr_val)
                }
            }
        } else {
            currentAttribute = elementName
        }
                
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String ) {
        if (string.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
            //print(string)
            if currentAttribute == "rdfs:label" {
                label = string
            } else if currentAttribute == "rdfs:comment" {
                comment = string
            } else if currentAttribute == "skos:altLabel" {
                synonyms.append(string)
            }
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        addConcept()
    }
}

public struct SpatialTaxonomy {
    nonisolated(unsafe) static public var concepts: [SpatialObjectConcept] = [SpatialObjectConcept]()
    
    static public func load(from url: URL, replaceExisting: Bool = true) {
        if replaceExisting {
            concepts.removeAll()
        }
        DispatchQueue.global(qos: .utility).async {
            let parser = XMLParser(contentsOf: url)!
            let myDelegate = TaxonomyParser()
            parser.delegate = myDelegate
            parser.parse()
            //print("\(concepts.count) concepts loaded")
            buildHierachy()
        }
    }
    
    static public func buildHierachy() {
        for concept in SpatialTaxonomy.concepts {
            if concept.parent == nil && concept.parentId != nil {
                let parent = getConcept(id: concept.parentId ?? "")
                if parent != nil {
                    concept.parent = parent!
                    parent!.addChild(concept)
                }
            }
        }
        //printConcepts()
    }
    
    static public func printConcepts() {
        for concept in SpatialTaxonomy.concepts {
            print("\(concept.label) \(concept.parentId ?? "") \(concept.parent != nil)")
        }
    }
    
    static public func getConcept(id: String) -> SpatialObjectConcept? {
        return SpatialTaxonomy.concepts.first(where: { $0.id == id })
    }
    
    static public func getConcept(label: String) -> SpatialObjectConcept? {
        return SpatialTaxonomy.concepts.first(where: { $0.label.lowercased() == label.lowercased() })
    }
    
    static public func searchConcept(_ query: String, precise: Bool = true) -> SpatialObjectConcept? {
        if let concept = getConcept(label: query) {
            return concept
        }
        for concept in SpatialTaxonomy.concepts.reversed() {
            for syn in concept.synonyms ?? [] {
                if syn.lowercased() == query.lowercased() {
                    return concept
                }
            }
        }
        if !precise && query.count > 2 {
            for concept in SpatialTaxonomy.concepts.reversed() {
                if concept.label.lowercased().contains(query.lowercased()) {
                    return concept
                }
            }
        }
        return nil
    }
    
    static public func topConcepts() -> [SpatialObjectConcept] {
        var list: [SpatialObjectConcept] = []
        for concept in SpatialTaxonomy.concepts {
            if concept.parent == nil {
                list.append(concept)
            }
        }
        //print("topLevel: \(list.count)")
        return list
    }
    
    static public func asText(prefix: String = "- ", indent: String = "  ") -> String {
        var str = ""
        for top in topConcepts() {
            str = str + top.asText(prefix: prefix, indent: indent)
        }
        return str
    }
}
