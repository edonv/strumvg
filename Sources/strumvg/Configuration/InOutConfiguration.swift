//
//  InOutConfiguration.swift
//  strumvg
//
//  Created by Edon Valdman on 3/3/25.
//

import Foundation
import ArgumentParser

struct InOutConfiguration: ParsableArguments {
    @Option(
        name: [.customLong("config"), .customShort("c")],
        help: .init(
            "A path to a file to use for styling configuration.",
            discussion: "Options set as command-line options override any options set in the specified config file. Options not set in the specified config file fall back on default values."
        ),
        completion: .file(extensions: ["json"])
    )
    var configFilePath: String?
    
    @Flag(help: "Source for input pattern string.")
    var inputSource: InputSource = .argument
    
    @Flag(help: "Destination for output SVG content.")
    var outputDestination: OutputDestination = .log
    
    enum InputSource: EnumerableFlag {
        case stdin
        case argument
        
        static func name(for value: InputSource) -> NameSpecification {
            switch value {
            case .stdin:
                return [.customShort("i"), .long]
            case .argument:
                return [.customShort("a"), .customLong("arg")]
            }
        }
    }
    
    enum OutputDestination: EnumerableFlag {
        case stdout
        case log
//        case file(String)
        
        static func name(for value: OutputDestination) -> NameSpecification {
            switch value {
            case .stdout:
                return [.customShort("o"), .long]
            case .log:
                return [.customShort("l"), .long]
//            case .file:
//                return [.short, .long]
            }
        }
    }
}
