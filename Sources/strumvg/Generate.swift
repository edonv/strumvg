//
//  Generate.swift
//  strumvg
//
//  Created by Edon Valdman on 2/25/25.
//

import Foundation
import StrumModels
import Plot

import PlotSVG
import PlotExtensions

internal let numberFormat = FloatingPointFormatStyle<CGFloat>()
    .precision(.fractionLength(...4))
    .grouping(.never)

extension strumvg {
    func generate(pattern: Pattern, size: CGSize? = nil) -> SVG {
        let rect = calcRect(for: pattern)
        
        let svgDeclAttrs: [Attribute<SVG.DeclarationContext>] = [
            size
                .map(\.width)
                .map { .width(.number($0)) },
            size
                .map(\.height)
                .map { .height(.number($0)) },
            .viewBox(
                minX: rect.origin.x,
                minY: rect.origin.y,
                width: rect.size.width,
                height: rect.size.height
            ),
            .attribute(named: "overflow", value: "visible")
        ].compactMap { $0 }
        
        let nodes = pattern.measures.indices
            .flatMap { self.generateMeasureNodes(for: $0, in: pattern.measures) }
        
        let svg = SVG(
            svgAttrs: svgDeclAttrs,
            [
                .element(
                    named: "g",
                    nodes: [
                        .attribute(
                            named: "key",
                            value: "measures"
                        )
                    ] + nodes + CollectionOfOne(
                        barlineNode(
                            at: CGFloat(rect.size.width) - style.barlineSizes.strokeWidth,
                            index: pattern.measures.count
                        )
                    )
                )
            ]
        )
        
        return svg
    }
    
    private func calcRect(for pattern: Pattern) -> CGRect {
        let patternContainsHeaderText = pattern.measures
            .contains { $0.groups.contains(where: \.containsHeaderText) }
        let patternContainsAnyTriplets = pattern.measures
            .contains(where: \.timing.triplet)
        
        var minY = patternContainsHeaderText ? -style.textSizes.headerTextHeight : 0
        
        /// `(number of strums) * (width + gap) - (1 gap) + (barline gap + 2*0.5*barline stroke width)`
        ///
        /// add barlines and gaps (and outer halves of stroke widths)
        let calcWidth = widthsOfMeasures(pattern.measures)
            + style.barlineSizes.strokeWidth
        
        /// `(<conditional> header text height) + (strum array height) + (beat text height) + (rhythm group stem height) + (<conditional> triplet text height, including padding above it)`
        ///
        /// This conditionally includes the header text, as the height will need to be stretched "outside" the standard bounds to include in the calculated `viewBox`.
        var calcHeight = style.strumSizes.height
            + style.textSizes.beatTextHeight
            + style.beamSizes.stemHeight
        
        if patternContainsHeaderText {
            calcHeight += style.textSizes.headerTextHeight
        }
        if patternContainsAnyTriplets {
            calcHeight += style.textSizes.triplet3TextOffsetY
        } else if pattern.measures.contains(where: { $0.timing.duration != .quarter }) {
            // add beam stroke width so its thickness isn't outside the viewBox
            // if it's quarter notes, then it won't be jutting out anyway
            calcHeight += style.beamSizes.strokeWidth / 2
        }
        
        let barlineHeight = style.barlineSizes.height(withStrumSizes: style.strumSizes)
        // if barlineHeight is taller than strum arrow, need to adjust rect bounds
        if barlineHeight > style.strumSizes.height {
            // update minY
            let halfBarlineHeight = barlineHeight / 2
            let barlineMinY = style.strumSizes.height / 2 - halfBarlineHeight
            
            if barlineMinY < minY {
                calcHeight += (minY - barlineMinY)
                minY = barlineMinY
            }
            
            // update height if barlineHeight is taller than entire viewBox
            // (uncommon, but cover case anyway)
            if barlineHeight > calcHeight {
                calcHeight += barlineHeight - calcHeight
            }
        }
        
        let barlineStrokeWidth = style.barlineSizes.strokeWidth
        return CGRect(
            origin: .init(
                // needs to not cut off first barline
                x: -barlineStrokeWidth / 2,
                y: minY
            ),
            size: .init(
                // needs to account for negative minX to not cut off last barline
                width: calcWidth + barlineStrokeWidth / 2,
                height: calcHeight
            )
        )
    }
    
    /// Excludes trailing strum gap, includes leading/trailing barline gaps.
    private func widthsOfMeasures<S: Sequence>(_ measures: S) -> CGFloat where S.Element == Measure {
        measures
            .map { m in
                let beatCount = m.groups.flatMap(\.strums).count
                /// Full group width, from left edge of first strum to right edge of last strum (excluding trailing strum gap after)
                let measureWidth = CGFloat(beatCount) * (style.strumSizes.width + style.strumSizes.gap)
                    - style.strumSizes.gap
                // Add leading barline
                return measureWidth + 2 * style.barlineSizes.gap(withStrumSizes: style.strumSizes)
            }
            .reduce(into: 0, +=)
    }
    
    private func generateMeasureNodes(
        for measureNum: Int,
        in allMeasures: [Measure]
    ) -> [Node<SVG.DocumentContext>] {
        let currentMeasure = allMeasures[measureNum]
        let content = generateNodes(in: currentMeasure)
        
        let widthUpToMeasure = widthsOfMeasures(allMeasures[..<measureNum])
        
        // Adding this measure's leading barline's gap
        let leadingMeasureSpace = widthUpToMeasure
            + style.barlineSizes.gap(withStrumSizes: style.strumSizes)
        
        return [
            barlineNode(at: widthUpToMeasure, index: measureNum),
            .element(
                named: "g",
                nodes: [
                    .attribute(named: "key", value: "measure\(measureNum)"),
                    .attribute(named: "transform", value: "translate(\(leadingMeasureSpace))"),
                ] + content
            ),
        ]
    }
    
    /// Barlines will be centered vertically against the strum arrows.
    private func barlineNode(at x: CGFloat, index: Int) -> Node<SVG.DocumentContext> {
        let halfBarlineHeight = style.barlineSizes.height(withStrumSizes: style.strumSizes) / 2
        
        let y1 = style.strumSizes.height / 2 - halfBarlineHeight
        let y2 = style.strumSizes.height / 2 + halfBarlineHeight
        
        return .element(
            named: "line",
            attributes: [
                .attribute(named: "key", value: "barline\(index)"),
                .attribute(named: "x1", value: x, format: numberFormat),
                .attribute(named: "y1", value: y1, format: numberFormat),
                .attribute(named: "x2", value: x, format: numberFormat),
                .attribute(named: "y2", value: y2, format: numberFormat),
                .attribute(named: "stroke-width", value: style.barlineSizes.strokeWidth, format: numberFormat),
                .attribute(named: "stroke", value: style.colors.rhythms),
            ]
        )
    }
    
    private func generateNodes(in measure: Measure) -> [Node<SVG.DocumentContext>] {
        let allStrums = measure.groups
            .flatMap(\.strums)
        
        let strs = createRhythmText(quantity: allStrums.count, noteLength: measure.timing)
        
        // MARK: Header Text
        let headers = allStrums
            .enumerated()
            .compactMap { i, strum in
                createStrumHeader(
                    content: strum.headingChar.map(String.init),
                    index: i,
                    countText: false
                )
            }
        let headersGroup = Node<SVG.DocumentContext>.element(
            named: "g",
            nodes: strumHeaderTextStaticAttrs + headers
        )
        
        // MARK: Strum Arrows
        let arrows = allStrums
            .enumerated()
            .map { i, strum -> Node<SVG.DocumentContext> in
                let arrow = createStrumArrow(strum: strum, duration: measure.timing.duration)
                let index = CGFloat(i)
                
                let translateX = (style.strumSizes.width + style.strumSizes.gap) * index
                
                return .element(
                    named: "g",
                    nodes: [
                        .attribute(named: "key", value: "strum\(i)"),
                        .attribute(
                            named: "transform",
                            value: "translate(\(translateX))"
                        ),
                        arrow,
                    ].compactMap { $0 }
                )
            }
        let arrowsGroup = Node<SVG.DocumentContext>.element(
            named: "g",
            nodes: arrowsStaticAttrs + arrows
        )
        
        // MARK: Count Characters
        let countChars = strs
            .enumerated()
            .map { i, str in
                return createStrumHeader(
                    content: str,
                    index: i,
                    countText: true
                )
            }
        let countCharsGroup = Node<SVG.DocumentContext>.element(
            named: "g",
            nodes: countCharStaticAttrs + countChars.compactMap { $0 }
        )
        
        // MARK: Note Groups
        let noteGroupsGroup = createNoteGroups(
            strums: allStrums,
            noteLength: measure.timing
        )
        
        return [
            headersGroup,
            arrowsGroup,
            countCharsGroup,
            noteGroupsGroup,
        ]
    }
    
    private func createRhythmText(
        quantity: Int,
        noteLength: Timing
    ) -> [String] {
        let triplet = noteLength.triplet
        
        return (0..<quantity).map { int in
            let i = Double(int)
            
            switch noteLength.duration {
            case .quarter:
                if triplet {
                    switch int % 3 {
                    case 0:
                        return "\(Int(Double(i / 3 + 1)))"
                    case 1:
                        return "+"
                    case 2:
                        return "a"
                    default:
                        return ""
                    }
                } else {
                    return "\(int + 1)"
                }
                
            case .eighth:
                if triplet {
                    switch int % 3 {
                    case 0:
                        return "\(Int(Double(i / 3 + 1)))"
                    case 1:
                        return "+"
                    case 2:
                        return "a"
                    default:
                        return ""
                    }
                } else {
                    if int % 2 == 0 {
                        return "\(Int((Double(i) / 2).rounded() + 1))"
                    } else {
                        return "+"
                    }
                }
                
            case .sixteenth:
                if triplet {
                    if int % 3 == 0 {
                        let v = Int(i / 6 + 1)
                        if int.isMultiple(of: 2) {
                            return "\(v)"
                        } else {
                            return "+"
                        }
                    } else {
                        return ""
                    }
                } else {
                    switch int % 4 {
                    case 0:
                        return "\(Int((Double(i) / 4).rounded()))"
                    case 1:
                        return "e"
                    case 2:
                        return "+"
                    case 3:
                        return "a"
                    default:
                        return ""
                    }
                }
            }
        }
    }
    
    private func createStrumHeader(
        content: String?,
        index: Int,
        countText: Bool
    ) -> Node<SVG.DocumentContext>? {
        guard let content else { return nil }
        
        let height = countText ? style.textSizes.beatTextHeight : style.textSizes.headerTextHeight
        let x = (style.strumSizes.width + style.strumSizes.gap) * CGFloat(index) + style.strumSizes.width / 2
        
        return Node<SVG.DocumentContext>.element(
            named: "text",
            nodes: [
                .text("\(content)"),
                .attribute(named: "key", value: "\(countText ? "count" : "head")\(index)"),
                .attribute(named: "x", value: x, format: numberFormat),
                .attribute(named: "y", value: height / 2, format: numberFormat),
                .attribute(named: "dominant-baseline", value: "central"),
            ]
        )
    }
    
    private var strumHeaderAndCountTextSharedAttrs: [Node<SVG.DocumentContext>] {
        [
            .attribute(named: "text-anchor", value: "middle"),
            .attribute(named: "stroke", value: "none"),
        ]
    }
    
    private var strumHeaderTextStaticAttrs: [Node<SVG.DocumentContext>] {
        [
            .attribute(named: "key", value: "heads"),
            .attribute(named: "transform", value: "translate(0 -\(style.textSizes.headerTextHeight))"),
            .attribute(named: "fill", value: style.colors.headers),
            .attribute(
                named: "font-size",
                value: style.textSizes.headerFontSize,
                format: numberFormat
            ),
            .attribute(named: "font-family", value: style.fonts.strumHeader.family),
            .attribute(named: "font-weight", value: style.fonts.strumHeader.weight),
            .attribute(named: "font-style", value: style.fonts.strumHeader.style),
        ] + strumHeaderAndCountTextSharedAttrs
    }
    
    private var countCharStaticAttrs: [Node<SVG.DocumentContext>] {
        [
            .attribute(named: "key", value: "counts"),
            .attribute(named: "transform", value: "translate(0 \(style.strumSizes.height))"),
            .attribute(named: "fill", value: style.colors.rhythms),
            .attribute(
                named: "font-size",
                value: style.textSizes.beatFontSize,
                format: numberFormat
            ),
            .attribute(named: "font-family", value: style.fonts.countChar.family),
            .attribute(named: "font-weight", value: style.fonts.countChar.weight),
            .attribute(named: "font-style", value: style.fonts.countChar.style),
        ] + strumHeaderAndCountTextSharedAttrs
    }
    
    private func createStrumArrow(
        strum: Strum,
        duration: NoteDuration
    ) -> Node<SVG.DocumentContext>? {
        let variant = strum.variant
        let width = style.strumSizes.width
        let height = style.strumSizes.height
        
        let strokeWidth = style.strumSizes.strokeWidth
        let headHeight = style.strumSizes.arrowHeadHeight
        
        let triangle: Node<SVG.DocumentContext> = .element(
            named: "polygon",
            nodes: [
                .attribute(
                    named: "points",
                    value: [
                        "0,\(headHeight)",
                        "\(width / 2),0",
                        "\(width),\(headHeight)",
                    ].joined(separator: " ")
                ),
                .attribute(named: "stroke", value: "none"),
            ]
        )
        
        // For more accurate placement when rotation is needed,
        // rotate around (0,0), then translate back into place
        let arrowRotationTransformAttr = Node<SVG.DocumentContext>.attribute(
            named: "transform",
            value: strum.direction == .down ? "rotate(180 0 0) translate(-\(width) -\(height))" : ""
        )
        
        switch variant {
        case .normal:
            let line = Node<SVG.DocumentContext>.element(
                named: "line",
                nodes: [
                    .attribute(named: "x1", value: width / 2, format: numberFormat),
                    .attribute(named: "y1", value: headHeight, format: numberFormat),
                    .attribute(named: "x2", value: width / 2, format: numberFormat),
                    .attribute(named: "y2", value: height, format: numberFormat),
                    .attribute(named: "stroke-width", value: strokeWidth, format: numberFormat),
                ]
            )
            
            return .element(
                named: "g",
                nodes: [
                    arrowRotationTransformAttr,
                    line,
                    triangle
                ]
            )
            
        case .arpeggio:
            let numWaves = 6
            
            let startingY = headHeight / 2
            let squiggleStartingY = headHeight * 0.85
            let squiggleHeight = height - squiggleStartingY
            let wavelength = squiggleHeight / CGFloat(numWaves)
            
            let amplitude = wavelength / 2
            
            // Squiggle
            let squigglePath = Node<SVG.DocumentContext>.element(
                named: "path",
                attributes: [
                    .attribute(
                        named: "d",
                        value: "M\(width / 2) \(startingY)l0 \(squiggleStartingY - startingY)q\(-amplitude) \(amplitude) "
                            + Array(repeating: "0 \(wavelength)", count: numWaves)
                                .joined(separator: "t")
                    ),
                    .attribute(
                        named: "stroke-width",
                        value: strokeWidth,
                        format: numberFormat
                    ),
                    .attribute(named: "fill", value: "none"),
                ]
            )
            
            return .element(
                named: "g",
                nodes: [
                    arrowRotationTransformAttr,
                    triangle,
                    squigglePath
                ]
            )
            
        case .muted:
            return Node<SVG.DocumentContext>.element(
                named: "path",
                nodes: [
                    .attribute(
                        named: "d",
                        // M 20 0 L 0 20 M 20 20 L 0 0 M 10 56 V 10
                        value: [
                            // move to top right of X
                            "M \(width) 0",
                            // draw to lower left of X
                            "L 0 \(width)",
                            // move to lower right of X
                            "M \(width) \(width)",
                            // draw to top left of X
                            "L 0 0",
                            // move to bottom of line
                            "M \(width / 2) \(height)",
                            // draw to top of line
                            "V \(width / 2)",
                        ].joined()
                    ),
                    .attribute(named: "fill", value: "none"),
                    .attribute(
                        named: "stroke-width",
                        value: strokeWidth,
                        format: numberFormat
                    ),
                    arrowRotationTransformAttr,
                ]
            )
            
        case .space:
            return nil
            
        case .rest:
            return Node<SVG.DocumentContext>.element(
                named: "g",
                nodes: [
                    restNode(
                        duration: duration,
                        width: width,
                        height: height
                    ),
                ]
            )
            
        case .other(let char):
            return .element(
                named: "text",
                nodes: [
                    .attribute(
                        named: "x",
                        value: width / 2,
                        format: numberFormat
                    ),
                    .attribute(
                        named: "y",
                        value: height / 2,
                        format: numberFormat
                    ),
                    .attribute(
                        named: "dominant-baseline",
                        value: "central"
                    ),
                    .attribute(
                        named: "stroke",
                        value: "none"
                    ),
                    .text(String(char)),
                ]
            )
        }
    }
    
    private var arrowsStaticAttrs: [Node<SVG.DocumentContext>] {
        [
            .attribute(named: "key", value: "strums"),
            .attribute(named: "fill", value: style.colors.arrows),
            .attribute(named: "stroke", value: style.colors.arrows),
            .attribute(
                named: "font-size",
                value: style.strumSizes.charStrumTextSize,
                format: numberFormat
            ),
            .attribute(
                named: "text-anchor",
                value: "middle"
            ),
            .attribute(named: "font-family", value: style.fonts.arrowText.family),
            .attribute(named: "font-weight", value: style.fonts.arrowText.weight),
            .attribute(named: "font-style", value: style.fonts.arrowText.style),
        ]
    }
    
    private func createNoteGroups(
        strums: [Strum],
        noteLength: Timing
    ) -> Node<SVG.DocumentContext> {
        let y = style.strumSizes.height + style.textSizes.beatTextHeight
        
        let triplet = noteLength.triplet
        let beamBarCount = noteLength.duration.beamBarCount
        
        let beatsPerGroup = triplet ? 3 : 2
        let quantity = Int(floor(Double(strums.count) / Double(beatsPerGroup)))
        
        return .element(
            named: "g",
            nodes: [
                .attribute(named: "key", value: "rhythmGroups"),
                .attribute(named: "transform", value: "translate(0 \(y))"),
                .attribute(named: "fill", value: style.colors.rhythms),
                .attribute(named: "stroke", value: style.colors.rhythms),
                .attribute(
                    named: "stroke-width",
                    value: style.beamSizes.strokeWidth,
                    format: numberFormat
                ),
                .attribute(named: "font-size", value: style.textSizes.tripletFontSize, format: numberFormat),
                .attribute(named: "text-anchor", value: "middle"),
                .attribute(named: "font-family", value: style.fonts.tripletText.family),
                .attribute(named: "font-weight", value: style.fonts.tripletText.weight),
                .attribute(named: "font-style", value: style.fonts.tripletText.style),
            ] + (0..<quantity).map { i in
                return createNoteGroup(
                    groupNum: i,
                    beatCount: beatsPerGroup,
                    triplet: triplet,
                    beamBarCount: beamBarCount
                )
            }
        )
    }
    
    /// - Parameters:
    ///   - groupNum: The index of the note group in the measure.
    ///   - beatCount: The number of strums in the group.
    ///   - triplet: Whether or not the group is a triplet.
    ///   - beamBarCount: The number of beams/flags to draw for the group.
    private func createNoteGroup(
        groupNum: Int,
        beatCount: Int,
        triplet: Bool,
        beamBarCount: Int
    ) -> Node<SVG.DocumentContext> {
        let beatCountFloat = CGFloat(beatCount)
        /// Full group width, from left edge of first strum to right edge of last strum (including gap after)
        let fullWidth = CGFloat(beatCountFloat) * (style.strumSizes.width + style.strumSizes.gap)
        
        /// `fullWidth` - (0.5 of strum space width on each end, which equals 1 full width)
        let beamWidth: CGFloat = fullWidth - style.strumSizes.width - style.strumSizes.gap
        
        let tripletTextElementY = style.beamSizes.stemHeight + style.textSizes.triplet3TextOffsetY
        let textEl: Node<SVG.DocumentContext>? = triplet ? .element(
            named: "text",
            nodes: [
                .text("3"), // triplet label
                .attribute(
                    named: "x",
                    value: beamWidth / 2,
                    format: numberFormat
                ),
                .attribute(
                    named: "y",
                    value: tripletTextElementY,
                    format: numberFormat
                ),
                .attribute(named: "stroke", value: "none"),
            ]
        ) : nil
        
        // M0,0 [v8 h50 V0]+
        let beamLength = beamWidth / (beatCountFloat - 1)
        // Add first path node
        var noteBeamsPathAttr = "M0,0"
        
        // Construct repeat segments
        var pathSegment = "v\(style.beamSizes.stemHeight)"
        // If at least 8th notes, draw first beam bar
        if beamBarCount > 0 {
            pathSegment += " h\(beamLength)"
        } else {
            // Otherwise, just move node to next stem
            pathSegment += " m\(beamLength),0"
        }
        pathSegment += " V0"
        
        // Append path string with repeating nodes
        noteBeamsPathAttr += Array(
            repeating: pathSegment,
            count: beatCount - 1
        )
        .joined(separator: " ")
        
        let noteBeamsPath = Node<SVG.DocumentContext>.element(
            named: "path",
            attributes: [
                .attribute(
                    named: "d",
                    value: noteBeamsPathAttr
                )
            ]
        )
        
        let extraBeamBars = beamBarCount - 1
        var extraBeamPaths = [Node<SVG.DocumentContext>]()
        if extraBeamBars > 0 {
            // Space out beams by 1.5*strokeWidth, or 1 (whichever is larger)
            let beamStrokeVerticalGap = style.beamSizes.beamStrokeVerticalGap
            
            extraBeamPaths = (0..<extraBeamBars).map { i in
                // <line x1="0" y1="4" x2="50" y2="4"></line>
                let y = style.beamSizes.stemHeight - CGFloat(i + 1) * beamStrokeVerticalGap
                return .element(
                    named: "line",
                    attributes: [
                        .attribute(named: "x1", value: "0"),
                        .attribute(named: "y1", value: y, format: numberFormat),
                        .attribute(named: "x2", value: beamWidth, format: numberFormat),
                        .attribute(named: "y2", value: y, format: numberFormat),
                    ]
                )
            }
        }
        
        let beamsGroup = Node<SVG.DocumentContext>.element(
            named: "g",
            nodes: [
                .attribute(named: "fill", value: "none"),
                noteBeamsPath,
            ] + extraBeamPaths
        )
        
        let x = CGFloat(groupNum) * fullWidth
        let translateX = x + style.strumSizes.width / 2
        
        return Node<SVG.DocumentContext>.element(
            named: "g",
            nodes: [
                [
                    .attribute(
                        named: "key",
                        value: "group\(groupNum)"
                    ),
                    .attribute(
                        named: "transform",
                        value: "translate(\(translateX.formatted(numberFormat)))"
                    )
                ],
                [beamsGroup, textEl]
                    .compactMap { $0 },
            ].flatMap { $0 }
        )
    }
}
