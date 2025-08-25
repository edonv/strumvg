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
    
    @Flag(
        help: .init(
            "Source for input pattern string.",
            discussion: "-i/--stdin uses the stdin as the source of the input pattern. -a/--arg uses a command argument as the source of the input pattern."
        )
    )
    var inputSource: InputSource = .argument
    
    @Argument(
        help: .init(
            "The string representation of a pattern.",
            discussion: "This argument requires the --argument flag."
        )
    )
    var patternString: String?
    
    @Flag(
        help: .init(
            "Destination for output SVG content.",
            discussion: "-o/--stdout uses the stdout as the output destination of the generated SVG string. -l/--log outputs the generated SVG string to the console."
        )
    )
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
