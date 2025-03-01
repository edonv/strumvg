//
//  PlotSVG.swift
//  strumvg
//
//  Created by Edon Valdman on 2/25/25.
//

import Foundation
import Plot

//extension XML {
//    enum SVGContext {}
//}

public struct SVG: DocumentFormat {
    private let document: Document<SVG>
    
    /// Create an HTML document with a collection of nodes that make
    /// up its elements and attributes. Start by specifying its root
    /// nodes, such as `.head()` and `.body()`, and then create any
    /// sort of hierarchy of elements and attributes from there.
    /// - parameter nodes: The root nodes of the document, which will
    /// be placed inside of an `<html>` element.
    public init(
        svgAttrs: [Attribute<SVG.DeclarationContext>],
        _ nodes: [Node<SVG.DocumentContext>]
    ) {
        document = Document<SVG>.custom(
            .xml(
                .version(1.0)
//                .attribute(
//                    named: "standalone",
//                    value: "no"
//                )
            ),
            .svg(svgAttrs: svgAttrs, nodes)
//            .doctype
            
//            Element.named("svg", nodes: nodes.map { $0. as! Node<Any> })
        )
//            .custom(withFormat: SVG.self, elements: [
////            .xml(.version(1.0), .encoding(.utf8)),
//            .named("svg", nodes: [])
////            Element(name: "svg", nodes: nodes)
//        ])
        
//        document.elements
//        document = Document(elements: [
//            .doctype("html"),
//            .html(.group(nodes))
//        ])
    }
    
    public func render() -> String {
        self.document.render()
    }
    
    public func render(indentedBy indentationKind: Indentation.Kind?) -> String {
        self.document.render(indentedBy: indentationKind)
    }
    
//    public init(document: Document<SVG>) {
//        self.document = document
//    }
}

public extension SVG {
    /// The root context of an SVG document.
    enum RootContext: SVGRootContext {}
    /// The context within an SVG document's `<svg>` declaration.
    enum DeclarationContext {}
    /// The user-facing root context of an SVG document.
    enum DocumentContext {}
}

/// Protocol adopted by all contexts that are at the root level of
/// an SVG-based document format.
public protocol SVGRootContext: XMLRootContext {}

extension Element where Context: SVGRootContext {
    static func svg(
        svgAttrs: [Attribute<SVG.DeclarationContext>],
        _ nodes: [Node<SVG.DocumentContext>]
    ) -> Element<Context> {
        Element<Context>.named(
            "svg",
            nodes: [
                .attribute(named: "xmlns", value: "http://www.w3.org/2000/svg"),
                .attribute(named: "version", value: "1.1"),
            ] + svgAttrs.map {
                .attribute(named: $0.name, value: $0.value)
            }
            + nodes.map {
                $0.node.convertToNode(withContext: Any.self)
            }
        )
    }
}
