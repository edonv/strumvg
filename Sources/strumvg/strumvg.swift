// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import StrumModels

import Plot
import PlotSVG

@main
struct strumvg: ParsableCommand {
    @Argument(help: "The string representation of a pattern.")
    var patternString: String?
    
    @OptionGroup
    var ioOptions: InOutOptions
    
    let options: ConfigOptions = .default
    
    func validate() throws {
        if ioOptions.inputSource == .argument
            && patternString == nil {
            throw ValidationError("`inputSource` flag set to `--arg` and the `patternString` argument is missing.")
        }
        
        if ioOptions.inputSource == .stdin
            && patternString != nil {
            throw ValidationError("`inputSource` flag set to `--stdin` and the `patternString` argument is present.")
        }
    }
    
    mutating func run() throws {
//        let string = "{xD} D u uD u-16t"
        let pattern = Pattern(rawValue: patternString)
//        print(pattern?.rawValue)
        
        guard let pattern else { return }
        
        let svg = generate(pattern: pattern)
        print(svg.render(indentedBy: .spaces(2)))
    }
}
