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
    
    @Argument(
        help: .init(
            "The string representation of a pattern.",
            discussion: "This argument requires the --argument flag."
        )
    )
    var patternString: String?
    
    @OptionGroup(title: "Output")
    var output: Output
    
    struct Output: ParsableArguments {
        @Flag(
            help: .init(
                "Destination for output SVG content.",
                discussion: "This option is mutually exclusive with the --file option."
            )
        )
        private var destinationType: DestinationType?
        
        @Option(
            name: [
                .customShort("f"),
                .customLong("file")
            ],
            help: .init(
                "Outputs the generated SVG string to a specified file path.",
                discussion: "This option is mutually exclusive with the --stdout and --log flags."
            ),
            completion: .file(extensions: ["svg"])
        )
        private var fileOutput: String? = nil
        
        enum CodingKeys: CodingKey {
            case destinationType
            case fileOutput
        }
        
        private(set) var destination: Destination!
        
        mutating func validate() throws {
            // Apply default value
            if destinationType == nil
                && fileOutput == nil {
                self.destinationType = .stdout
            }
            
            switch destinationType {
            case .stdout where fileOutput == nil:
                self.destination = .stdout
                return
            case .log where fileOutput == nil:
                self.destination = .log
                return
            case nil:
                if let fileOutput {
                    self.destination = .file(path: fileOutput)
                    return
                }
            default:
                // destinationType != nil
                // both non-nil
                if fileOutput != nil {
                    throw ValidationError("Both a `destinationType` flag and `--file` option are present. They are mutually exclusive.")
                }
            }
            
            // both nil
            throw ValidationError("Neither a `destinationType` flag nor the `--file` option is present. One of them must be present.")
        }
        
        private enum DestinationType: EnumerableFlag {
            case stdout
            case log
            
            static func name(for value: DestinationType) -> NameSpecification {
                switch value {
                case .stdout:
                    return [.customShort("o"), .long]
                case .log:
                    return [.customShort("l"), .long]
                }
            }
            
            static func help(for value: DestinationType) -> ArgumentHelp? {
                switch value {
                case .stdout:
                    return "Outputs the generated SVG string to the stdout."
                case .log:
                    return "Outputs the generated SVG string to the console."
                }
            }
        }
        
        enum Destination {
            case stdout
            case log
            case file(path: String)
        }
    }
}
