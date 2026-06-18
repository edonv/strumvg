//
//  InOutConfiguration.swift
//  strumvg
//
//  Created by Edon Valdman on 3/3/25.
//

import Foundation
import ArgumentParser

package struct InOutConfiguration: ParsableArguments {
    package init() {}
    
    @Option(
        name: [.customLong("config"), .customShort("c")],
        help: .init(
            "A path to a file to use for styling configuration.",
            discussion: "Options set as command-line options override any options set in the specified config file. Options not set in the specified config file fall back on default values."
        ),
        completion: .file(extensions: ["json", "yml", "yaml"])
    )
    package var configFilePath: String?
    
    @OptionGroup(title: "Input")
    package var input: Input
    
    package struct Input: ParsableArguments {
        package init() {}
        
        @Flag(
            help: .init(
                "Source for input pattern string.",
                discussion: "This option is mutually exclusive with the --file option."
            )
        )
        private var sourceType: SourceType?
        
        @Option(
            name: [
                .customShort("a"),
                .customLong("arg")
            ],
            help: .init(
                "Uses a comman argument as the source of the input pattern.",
                discussion: "This option is mutually exclusive with the --stdin flag."
            )
        )
        private var patternString: String? = nil
        
        package enum CodingKeys: CodingKey {
            case sourceType
            case patternString
        }
        
        package private(set) var source: Source!
        
        package mutating func validate() throws {
            // Apply default value
            if sourceType == nil
                && patternString == nil {
                self.sourceType = .stdin
            }
            
            switch sourceType {
            case .stdin where patternString == nil:
                self.source = .stdin
                return
            case nil:
                if let patternString {
                    self.source = .argument(pattern: patternString)
                    return
                }
            default:
                // sourceType != nil
                // both non-nil
                if patternString != nil {
                    throw ValidationError("Both a `sourceType` flag and `--arg` option are present. They are mutually exclusive.")
                }
            }
            
            // both nil
            throw ValidationError("Neither a `sourceType` flag nor the `--arg` option is present. One of them must be present.")
        }
        
        private enum SourceType: EnumerableFlag {
            case stdin
            
            static func name(for value: SourceType) -> NameSpecification {
                switch value {
                case .stdin:
                    return [.customShort("i"), .long]
                }
            }
            
            static func help(for value: SourceType) -> ArgumentHelp? {
                switch value {
                case .stdin:
                    return "Uses the stdin as the source of the input pattern."
                }
            }
        }
        
        package enum Source {
            case stdin
            case argument(pattern: String)
        }
    }
    
    @OptionGroup(title: "Output")
    package var output: Output
    
    package struct Output: ParsableArguments {
        package init() {}
        
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
        
        package private(set) var destination: Destination!
        
        package mutating func validate() throws {
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
        
        package enum Destination {
            case stdout
            case log
            case file(path: String)
        }
    }
}
