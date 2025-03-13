//
//  ConfigOptions.swift
//  strumvg
//
//  Created by Edon Valdman on 2/25/25.
//

import Foundation
import ArgumentParser

struct ConfigOptions: ParsableArguments {
    @OptionGroup(title: "Colors")
    var colors: Colors
    
    struct Colors: ParsableArguments {
        @Option(
            name: .customLong("arrow-color"),
            help: "The color of the arrows."
        )
        var arrows: String = "#000000"
        
        @Option(
            name: .customLong("rhythm-color"),
            help: "The color of the rhythm text and stems below the arrows."
        )
        var rhythms: String = "#555555"
        
        @Option(
            name: .customLong("header-color"),
            help: "The color of the articulations and header text above the arrows."
        )
        var headers: String = "#000000"
    }
    
    @OptionGroup(title: "Text Sizes")
    var textSizes: TextSizes
    
    struct TextSizes: ParsableArguments {
        @Option(
            help: "The height of the space reserved for rhythm text below the arrows."
        )
        var beatTextHeight: CGFloat = 30
        
        @Option(
            help: "The actual font-size of the rhythm text below the arrows, relative to its height."
        )
        var beatFontSize: CGFloat = 0.8
        
        @Option(
            help: "The height of the space reserved for articulations and header text above the arrows."
        )
        var headerTextHeight: CGFloat = 30
        
        @Option(
            help: "The actual font-size of the articulations and header text above the arrows, relative to its height."
        )
        var headerFontSize: CGFloat = 0.8
    }
    
    @OptionGroup(title: "Strum Sizes")
    var strumSizes: StrumSizes
    
    struct StrumSizes: ParsableArguments {
        @Option(
            name: .customLong("strum-width"),
            help: .init(
                "The width of each strum arrow.",
                discussion: "This is also the width of the space reserved for each \"rhythmic column\" composed of arrow, header text, and beat text."
            )
        )
        var width: CGFloat = 20
        
        @Option(
            name: .customLong("strum-height"),
            help: "The height of each strum arrow."
        )
        var height: CGFloat = 80
        
        @Option(
            name: .customLong("strum-gap"),
            help: "The horizontal space between each strum "
        )
        var gap: CGFloat = 30
    }
    
    @OptionGroup(title: "Beam Sizes")
    var beamSizes: BeamSizes
    
    struct BeamSizes: ParsableArguments {
        @Option(
            name: .customLong("beam-stroke-width"),
            help: "The stroke width of the rhythm stems/beams below the arrows."
        )
        var strokeWidth: CGFloat = 2
        
        @Option(
            name: .customLong("beam-steam-height"),
            help: "The vertical length of the beam stems."
        )
        var stemHeight: CGFloat = 8
    }
    
    
    
}
