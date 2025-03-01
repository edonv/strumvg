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

private let numberFormat = FloatingPointFormatStyle<CGFloat>()
    .precision(.fractionLength(...4))
private let FIX_FACTOR: CGFloat = 0.8

extension strumvg {
    func generate(pattern: Pattern, size: CGSize? = nil) -> SVG {
        let allStrums = pattern.groups
            .flatMap(\.strums)
        
//        const chars = createTaktChars(strums.length, noteLength);
        let strs = createRhythmText(quantity: allStrums.count, noteLength: pattern.timing)
        
        let calcWidth = (options.strumWidth + options.strumGap) * CGFloat(pattern.totalStrums) - options.strumGap
        let calcHeight = options.strumHeight + options.headerHeight + 2 * options.beatTextHeight
        
        // MARK: StrumHeader - P1
        let headers = allStrums
            .enumerated()
            .compactMap { i, strum in
                createStrumHeader(
                    content: strum.headingChar.map(String.init),
                    index: i,
                    rhythm: false
                )
            }
        
        // MARK: StrumArrow
        let arrows = allStrums
            .enumerated()
            .map { i, strum -> Node<SVG.DocumentContext> in
                let arrow = createStrumArrow(strum: strum)
                let index = CGFloat(i)
                
                let group = Node<SVG.DocumentContext>.element(
                    named: "g",
                    nodes: [
                        .attribute(named: "key", value: "strum\(i)"),
                        .attribute(
                            named: "style",
                            value: "transform-box: fill-box; transform-origin: center;"
                        ),
                        .attribute(
                            named: "transform",
                            value: "translate(\((options.strumWidth + options.strumGap) * index),\(options.headerHeight))\(strum.direction == .down ? " rotate(180 0 0)" : "")"
                        ),
                        arrow,
                    ].compactMap { $0 }
                )
                
                    
//                let group = document.createElementNS("http://www.w3.org/2000/svg", "g");
                
//                group.setAttributeNS(null, "key", `strum\(i)`);
//                group.style.transformBox = "fill-box";
//                group.style.transformOrigin = "center";
//                group.setAttributeNS(
//                    null,
//                    "transform",
//                    `translate(\((_options.strumWidth + _options.strumGap) * i),${_options.headerHeight
//                    })\(s.direction === "down" ? " rotate(180 0 0)" : "")`
//                );
                
//                const arrow = createStrumArrow({
//                    ...s,
//                    height: _options.strumHeight,
//                    width: _options.strumWidth,
//                    fill: _options.arrowColor,
//                });
                
//                if (arrow) {
//                    group.appendChild(arrow);
//                }
                
                return group
            }
        
        // MARK: Char StrumHeader
        let charHeaders = strs
            .enumerated()
            .map { i, str in
                return createStrumHeader(
                    content: str,
                    index: i,
                    rhythm: true
                )
//                return createStrumHeader(
//                    {
//                        key: `head${i}`,
//                        height: _options.beatTextHeight,
//                        width: _options.strumWidth,
//                        fill: _options.rhythmColor,
//                        fontSize: _options.beatTextFontSize,
//                        y: _options.headerHeight + _options.strumHeight * FIX_FACTOR,
//                    x:
//                        (_options.strumWidth + _options.strumGap) * i +
//                        _options.strumWidth / 2,
//                    },
//                    str
//                );
            }
        
        let noteGroupsGroup = createNoteGroups(
            strums: allStrums,
//            options: _options,
            noteLength: pattern.timing
        )
        
        let svgDeclAttrs: [Attribute<SVG.DeclarationContext>] = [
            size
                .map(\.width)
                .map { .width(.number($0)) },
            size
                .map(\.height)
                .map { .height(.number($0)) },
            .viewBox(
                width: calcWidth,
                height: calcHeight
            ),
            .attribute(named: "overflow", value: "visible")
        ].compactMap { $0 }
        
        let svg = SVG(
            svgAttrs: svgDeclAttrs,
//            [
//            [
//                .attribute(named: "xmlns", value: "http://www.w3.org/2000/svg"),
//                .attribute(named: "version", value: "1.1"),
                
//                .attribute(
//                    named: "width",
//    //                value: calcWidth
//    //                      .formatted(numberFormat)
//                    value: size
//                        .map(\.width)
//                        .map { $0.formatted(numberFormat) }
//                ),
//                .attribute(
//                    named: "height",
//    //                value: calcHeight
//    //                      .formatted(numberFormat)
//                    value: size
//                        .flatMap { $0.height }
//                        .map { $0.formatted(numberFormat) }
//                ),
//                .attribute(
//                    named: "viewBox",
//                    value: "0 0 \(calcWidth.formatted(numberFormat)) \(calcHeight.formatted(numberFormat))"
//                ),
//                .attribute(
//                    named: "overflow",
//                    value: "visible"
//                )
//            ],
            [
                headers,
                arrows,
                charHeaders
                    .compactMap { $0 },
                [noteGroupsGroup],
            ].flatMap { $0 }
        )
        
//        svg.append(
//            ...[...headers, ...arrows, ...charHeaders, noteGroups].flatMap((el) => el)
//        );
        
        return svg
    }
    
    private func createRhythmText(
        quantity: Int,
        noteLength: Timing
    ) -> [String] {
        let triplet = noteLength.triplet
        
        return (0..<quantity).map { i in
            switch noteLength.duration {
            case .quarter:
                if triplet {
                    if i.isMultiple(of: 3) {
                        return "\(i / 3 + 1)"
                    } else {
                        return ""
                    }
                } else {
                    return "\(i + 1)"
                }
                
            case .eighth:
                if triplet {
                    if i.isMultiple(of: 3) {
                        return "\(i / 3 + 1)"
                    } else {
                        return ""
                    }
                } else {
                    if i.isMultiple(of: 2) {
                        return "\(Int((Double(i) / 2).rounded() + 1))"
                    } else {
                        return "&"
                    }
                }
                
            case .sixteenth:
                if triplet {
                    if i.isMultiple(of: 3) {
                        let v = i / 3 + 1
                        if v.isMultiple(of: 2) {
                            return "\(v)"
                        } else {
                            return "&"
                        }
                    } else {
                        return ""
                    }
                } else {
                    let odd = !i.isMultiple(of: 2)
                    let halfOdd = !(i / 2).isMultiple(of: 2)
                    if odd {
                        return ""
                    } else if halfOdd {
                        return "&"
                    } else {
                        return "\(Int((Double(i) / 4).rounded() + 1))"
                    }
                }
            }
        }
    }
    
    private func createStrumHeader(
        content: String?,
        index: Int,
        rhythm: Bool
    ) -> Node<SVG.DocumentContext>? {
        guard let content else { return nil }
        
        let height = rhythm ? options.beatTextHeight : options.headerHeight
        let width = options.strumWidth
        let fill = rhythm ? options.rhythmColor : options.articulationColor
        let fontSize = rhythm ? options.beatTextFontSize : options.headerFontSize
        let x = (options.strumWidth + options.strumGap) * CGFloat(index) + options.strumWidth / 2
        let yBase = rhythm ? options.headerHeight + options.strumHeight * FIX_FACTOR : 0
        
        return Node<SVG.DocumentContext>.element(
            named: "text",
            nodes: [
                .text("\(content)"),
                .attribute(named: "key", value: "head\(index)"),
                .attribute(named: "height", value: height, format: numberFormat),
                .attribute(named: "width", value: width, format: numberFormat),
                .attribute(named: "fill", value: fill),
                .attribute(named: "x", value: x, format: numberFormat),
                .attribute(named: "y", value: yBase + height * fontSize, format: numberFormat),
                .attribute(named: "font-size", value: height * fontSize, format: numberFormat),
                .attribute(named: "textLength", value: width, format: numberFormat),
                .attribute(named: "text-anchor", value: "middle"),
                .attribute(named: "font-family", value: "sans-serif"),
                .attribute(named: "font-weight", value: "bold"),
            ]
        )
    }
    
    private func createStrumArrow(
        strum: Strum
    ) -> Node<SVG.DocumentContext>? {
        let variant = strum.variant
        //   direction = "up",
        let height = options.strumHeight /*?? 100*/
        let width = options.strumWidth /*?? 50*/
        let fill = options.arrowColor
        let strokeWidth: CGFloat = 0.2
        let headHeight: CGFloat = 0.2
        
//        let pathEl: SVGPathElement
        let pathEl: Node<SVG.DocumentContext>
//        let gEl: SVGGElement
        let gEl: Node<SVG.DocumentContext>
//        let rectEl1: SVGRectElement
        let rectEl1: Node<SVG.DocumentContext>
//        let rectEl2: SVGRectElement
        let rectEl2: Node<SVG.DocumentContext>
        
        switch variant {
        case .normal:
//            pathEl = document.createElementNS("http://www.w3.org/2000/svg", "path");
            pathEl = Node<SVG.DocumentContext>.element(
                named: "path",
                attributes: [
                    .attribute(
                        named: "d",
                        value: "m0,\(height * headHeight)l\(width / 2),\(-height * headHeight)l\(width / 2),\(height * headHeight)l\((-width * (1 - strokeWidth)) / 2),0l0,\(height / 2)l\(-width * strokeWidth),0l0,\(-height / 2)l\(-width / 4),0z"
                    ),
                    .attribute(
                        named: "stroke-width",
                        value: "0"
                    )
                ]
            )
            
//            pathEl.setAttributeNS(
//                null,
//                "d",
//                `m0,\(height * headHeight)l\(width / 2),\(-height * headHeight)l${width / 2
//                },\(height * headHeight)l\((-width * (1 - strokeWidth)) / 2),0l0,${height / 2
//                }l\(-width * strokeWidth),0l0,\(-height / 2)l\(-width / 4),0z`
//            );
//            pathEl.setAttributeNS(null, "stroke-width", "0");
            // ...props
//            Object.keys(pathProps).forEach((key) => {
//                pathEl.setAttributeNS(null, key, pathProps[key]?.toString());
//            });
            
            return pathEl
            
        case .arpeggio:
            let offsetY = height * headHeight * 0.9
            let numWaves = 6
            let amplitude = 6
            // let offsetX = amplitude * 2;
            let wavelength = height / CGFloat(numWaves) / CGFloat(2)
            
            // Triangle
            let pathEl1 = Node<SVG.DocumentContext>.element(
                named: "path",
                attributes: [
                    .attribute(
                        named: "d",
                        value: "M\(0),\(height * headHeight)l\(width / 2),\(-height * headHeight)l\(width / 2),\(height * headHeight)"
                    ),
                    .attribute(named: "stroke-width", value: "0")
                ]
            )

//            const pathEl1 = document.createElementNS(
//                "http://www.w3.org/2000/svg",
//                "path"
//            );
//            pathEl1.setAttributeNS(
//                null,
//                "d",
//                "M\(0),\(height * headHeight)l\(width / 2),\(-height * headHeight)l\(width / 2),\(height * headHeight)"
//            );
//            pathEl1.setAttributeNS(null, "stroke-width", "0");
            // ...props
//            Object.keys(pathProps).forEach((key) => {
//                pathEl1.setAttributeNS(null, key, pathProps[key]?.toString());
//            });
//            
            // Squiggle
            let pathEl2 = Node<SVG.DocumentContext>.element(
                named: "path",
                attributes: [
                    .attribute(
                        named: "d",
                        value: "M\(width / 2) , \(offsetY / 2)l0 \(offsetY / 2)" +
                        (0..<numWaves)
                            .map { i in
                                "q\(i % 2 == 0 ? -amplitude : amplitude) \(wavelength / 2) , \(0) \(wavelength)"
                            }
                            .joined(separator: ", ")
                    ),
                    .attribute(
                        named: "stroke-width",
                        value: width * strokeWidth,
                        format: numberFormat
                    ),
                    .attribute(named: "fill", value: "transparent"),
                    .attribute(named: "stroke", value: fill /*?? ""*/)
                ]
            )
//            const pathEl2 = document.createElementNS(
//                "http://www.w3.org/2000/svg",
//                "path"
//            );
//            pathEl2.setAttributeNS(
//                null,
//                "d",
//                `M\(width / 2) , \(offsetY / 2)l0 \(offsetY / 2)` +
//                new Array(numWaves)
//                    .fill(0)
//                    .map(
//                        (_, i) =>
//                        `q\(i % 2 === 0 ? -amplitude : amplitude) ${wavelength / 2
//                        } , \(0) \(wavelength)`
//                    )
//                    .join(", ")
//            );
//            pathEl2.setAttributeNS(
//                null,
//                "stroke-width",
//                (width * strokeWidth).toString()
//            );
            // ...props (do it before the remaining attributes, as they need to override some of these properties)
//            Object.keys(pathProps).forEach((key) => {
//                pathEl2.setAttributeNS(null, key, pathProps[key]?.toString());
//            });
//            pathEl2.setAttributeNS(null, "fill", "transparent");
//            pathEl2.setAttributeNS(null, "stroke", pathProps.fill ?? "");
            
            gEl = Node<SVG.DocumentContext>.element(named: "g", nodes: [pathEl1, pathEl2])
            
//            gEl = document.createElementNS("http://www.w3.org/2000/svg", "g");
//            gEl.appendChild(pathEl1);
//            gEl.appendChild(pathEl2);
            return gEl

//        case .accent:
//            let newStrokeWidth = min(1, strokeWidth * 2)
//            
//            pathEl = Node<XML.DocumentContext>.element(
//                named: "path",
//                attributes: [
//                    .attribute(
//                        named: "d",
//                        value: "m0,\(height * headHeight)l\(width / 2),\(-height * headHeight)l\(width / 2),\(height * headHeight)l\((-width * (1 - newStrokeWidth)) / 2),0l0,\(height / 2)l\(-width * newStrokeWidth),0l0,\(-height / 2)l\(-width / 4),0z"
//                    ),
//                    .attribute(named: "stroke-width", value: "0")
//                ]
//            )
////            pathEl = document.createElementNS("http://www.w3.org/2000/svg", "path");
//            
////            pathEl.setAttributeNS(
////                null,
////                "d",
////                `m0,\(height * headHeight)l\(width / 2),\(-height * headHeight)l\(width / 2),\(height * headHeight)l\((-width * (1 - newStrokeWidth)) / 2),0l0,\(height / 2)l\(-width * newStrokeWidth),0l0,\(-height / 2)l\(-width / 4),0z`
////            );
////            pathEl.setAttributeNS(null, "stroke-width", "0");
//            // ...props
////            Object.keys(pathProps).forEach((key) => {
////                pathEl.setAttributeNS(null, key, pathProps[key]?.toString());
////            });
//            
//            return pathEl
            
        case .muted:
            pathEl = Node<SVG.DocumentContext>.element(
                named: "path",
                attributes: [
                    .attribute(
                        named: "d",
                        value: "m0,\(height * headHeight)l\(width),0l\((-width * (1 - strokeWidth)) / 2),0l0,\(height / 2)l\(-width * strokeWidth),0l0,\(-height / 2)l\(-width / 4),0z"
                    ),
                    .attribute(named: "stroke-width", value: "0")
                ]
            )

//            pathEl = document.createElementNS("http://www.w3.org/2000/svg", "path");
            
//            pathEl.setAttributeNS(
//                null,
//                "d",
//                `m0,\(height * headHeight)l\(width),0l\((-width * (1 - strokeWidth)) / 2),0l0,\(height / 2)l\(-width * strokeWidth),0l0,\(-height / 2)l\(-width / 4),0z`
//            );
//            pathEl.setAttributeNS(null, "stroke-width", "0");
//            // ...props
//            Object.keys(pathProps).forEach((key) => {
//                pathEl.setAttributeNS(null, key, pathProps[key]?.toString());
//            });
            
            let rectElAttrs: [Attribute<SVG.DocumentContext>] = [
                .attribute(
                    named: "width",
                    value: width * strokeWidth,
                    format: numberFormat
                ),
                .attribute(
                    named: "height",
                    value: height * headHeight * 2,
                    format: numberFormat
                ),
                .attribute(
                    named: "x",
                    value: width / 2 - (width * strokeWidth) / 2,
                    format: numberFormat
                ),
                .attribute(
                    named: "style",
                    value: "transform-box: fill-box; transform-origin: center;"
                ),
            ]
            
//            rectEl1 = document.createElementNS("http://www.w3.org/2000/svg", "rect");
            rectEl1 = Node<SVG.DocumentContext>.element(
                named: "rect",
                attributes: [
                    rectElAttrs,
                    [.attribute(named: "transform", value: "rotate(45 0 0)")]
                ].flatMap { $0 }
            )
            
//            rectEl1.setAttributeNS(null, "width", (width * strokeWidth).toString());
//            rectEl1.setAttributeNS(
//                null,
//                "height",
//                (height * headHeight * 2).toString()
//            );
//            rectEl1.setAttributeNS(
//                null,
//                "x",
//                (width / 2 - (width * strokeWidth) / 2).toString()
//            );
//            rectEl1.style.transformBox = "fill-box";
//            rectEl1.style.transformOrigin = "center";
//            rectEl1.setAttributeNS(null, "transform", "rotate(45 0 0)");
//            // ...props
//            Object.keys(pathProps).forEach((key) => {
//                rectEl1.setAttributeNS(null, key, pathProps[key]?.toString());
//            });
            
            rectEl2 = Node<SVG.DocumentContext>.element(
                named: "rect",
                attributes: [
                    rectElAttrs,
                    [.attribute(named: "transform", value: "rotate(-45 0 0)")]
                ].flatMap { $0 }
            )
            
//            rectEl2 = rectEl1.cloneNode() as SVGRectElement;
//            rectEl2.setAttributeNS(null, "transform", "rotate(-45 0 0)");
            
            gEl = Node<SVG.DocumentContext>.element(
                named: "g",
                nodes: [
                    pathEl,
                    rectEl1,
                    rectEl2,
                ]
            )
//            gEl = document.createElementNS("http://www.w3.org/2000/svg", "g");
//            gEl.appendChild(pathEl);
//            gEl.appendChild(rectEl1);
//            gEl.appendChild(rectEl2);
            return gEl
            
        case .space:
            return nil
            
        case .rest:
            let h_factor: CGFloat = 3
            
            let rectElAttrs: [Attribute<SVG.DocumentContext>] = [
                .attribute(
                    named: "y",
                    value: (height / 4) * (1 - 1 / h_factor),
                    format: numberFormat
                ),
                .attribute(
                    named: "width",
                    value: width / 4,
                    format: numberFormat
                ),
                .attribute(
                    named: "height",
                    value: height / h_factor,
                    format: numberFormat
                ),
            ]
            
            rectEl1 = Node<SVG.DocumentContext>.element(
                named: "rect",
                attributes: [
                    rectElAttrs,
                    [.attribute(
                        named: "x",
                        value: 0 + width / 8,
                        format: numberFormat
                    )]
                ].flatMap { $0 }
            )
            
//            rectEl1 = document.createElementNS("http://www.w3.org/2000/svg", "rect");
//            rectEl1.setAttributeNS(
//                null,
//                "y",
//                ((height / 4) * (1 - 1 / h_factor)).toString()
//            );
//            rectEl1.setAttributeNS(null, "x", (0 + width / 8).toString());
//            rectEl1.setAttributeNS(null, "width", (width / 4).toString());
//            rectEl1.setAttributeNS(null, "height", (height / h_factor).toString());
//            // ...props
//            Object.keys(pathProps).forEach((key) => {
//                rectEl1.setAttributeNS(null, key, pathProps[key]?.toString());
//            });
            
            rectEl2 = Node<SVG.DocumentContext>.element(
                named: "rect",
                attributes: [
                    rectElAttrs,
                    [.attribute(
                        named: "x",
                        value: width / 2 + width / 8,
                        format: numberFormat
                    )]
                ].flatMap { $0 }
            )
            
//            rectEl2 = rectEl1.cloneNode() as SVGRectElement;
//            rectEl2.setAttributeNS(null, "x", (width / 2 + width / 8).toString());
            
            gEl = Node<SVG.DocumentContext>.element(
                named: "g",
                nodes: [
                    rectEl1,
                    rectEl2,
                ]
            )
            
//            gEl = document.createElementNS("http://www.w3.org/2000/svg", "g");
//            gEl.appendChild(rectEl1);
//            gEl.appendChild(rectEl2);
            return gEl
            
        case .other(let char):
//            const textEl = document.createElementNS(
//                "http://www.w3.org/2000/svg",
//                "text"
//            );
            let textEl = Node<SVG.DocumentContext>.element(
                named: "text",
                nodes: [
                    .attribute(
                        named: "y",
                        value: height / 2,
                        format: numberFormat
                    ),
                    .attribute(
                        named: "font-size",
                        value: height / 2,
                        format: numberFormat
                    ),
                    .attribute(
                        named: "x",
                        value: width / 2,
                        format: numberFormat
                    ),
                    .attribute(
                        named: "text-anchor",
                        value: "middle"
                    ),
                    .attribute(
                        named: "font-family",
                        value: "sans-serif"
                    ),
                    .attribute(
                        named: "font-weight",
                        value: "bold"
                    ),
                    .attribute(
                        named: "textLength",
                        value: width,
                        format: numberFormat
                    ),
                    .attribute(
                        named: "lengthAdjust",
                        value: "spacingAndGlyphs"
                    ),
                    .attribute(
                        named: "width",
                        value: width,
                        format: numberFormat
                    ),
                    .text(String(char)),
                ]
            )
            
//            // ...props
//            Object.keys(pathProps).forEach((key) => {
//                rectEl1.setAttributeNS(null, key, pathProps[key]?.toString());
//            });
//            
//            textEl.setAttributeNS(null, "y", (height / 2).toString());
//            textEl.setAttributeNS(null, "font-size", (height / 2).toString());
//            textEl.setAttributeNS(null, "x", (width / 2).toString());
//            textEl.setAttributeNS(null, "text-anchor", "middle");
//            textEl.setAttributeNS(null, "font-family", "sans-serif");
//            textEl.setAttributeNS(null, "font-weight", "bold");
//            textEl.setAttributeNS(null, "textLength", width.toString());
//            textEl.setAttributeNS(null, "lengthAdjust", "spacingAndGlyphs");
//            textEl.setAttributeNS(null, "width", width.toString());
            
//            const textContent = document.createTextNode(variant);
//            textEl.appendChild(textContent);
            
            return textEl
        }
    }
    
    private func createNoteGroups(
        strums: [Strum],
        noteLength: Timing
    ) -> Node<SVG.DocumentContext> {
        let y = options.headerHeight + options.strumHeight * FIX_FACTOR + options.beatTextHeight
        
        let triplet = noteLength.triplet
        let horizontalStrokes = noteLength.duration.horizontalStrokeCount
        
        let subdivision = triplet ? 3 : 2
        let quantity = Int(floor(Double(strums.count) / Double(subdivision)))
        
        let attrs: [Node<SVG.DocumentContext>] = (0..<quantity).map { i in
            return createNoteGroup(
                quantity: subdivision,
                triplet: triplet,
                horizontalStrokes: horizontalStrokes,
                x: CGFloat(subdivision) * (options.strumWidth + options.strumGap) * CGFloat(i) + options.strumWidth / 2,
                y: y,
                width: CGFloat(subdivision) * (options.strumWidth + options.strumGap)
                
                //                    beamStrokeWidth: options.beamStrokeWidth,
                //                    fill: options.rhythmColor,
                //                    beamHeight: options.beamHeight,
                //                    horizontalStrokes: horizontalStrokes,
                //                    width: subdivision * (options.strumWidth + options.strumGap),
                //                    y: y,
                //                    x:
                //                    subdivision * (options.strumWidth + options.strumGap) * i +
                //                    options.strumWidth / 2,
                //                    subtitle: triplet ? "3" : undefined,
            )
        }
        
//        const gEl = document.createElementNS("http://www.w3.org/2000/svg", "g");
        return Node<SVG.DocumentContext>.element(
            named: "g",
            nodes: attrs
        )
        
//        const groups = new Array(quantity).fill(0).map((_, i) => {
//            return createNoteGroup({
//                quantity: subdivision,
//                beamStrokeWidth: options.beamStrokeWidth,
//                fill: options.rhythmColor,
//                beamHeight: options.beamHeight,
//                horizontalStrokes: horizontalStrokes,
//                width: subdivision * (options.strumWidth + options.strumGap),
//                y: y,
//            x:
//                subdivision * (options.strumWidth + options.strumGap) * i +
//                options.strumWidth / 2,
//                subtitle: triplet ? "3" : undefined,
//            });
//        });
        
//        gEl.append(...groups);
        
//        return gEl;
    }
    
    private func createNoteGroup(
        quantity: Int,
        triplet: Bool,
        horizontalStrokes: Int,
        x: CGFloat,
        y: CGFloat,
        width: CGFloat
    ) -> Node<SVG.DocumentContext> {
        let quantityFloat = CGFloat(quantity)
        let fill = options.rhythmColor
        
        let textEl: Node<SVG.DocumentContext>?
        if triplet {
            textEl = .element(
                named: "text",
                nodes: [
                    .text("3"), // triplet label
                    
                    .attribute(
                        named: "x",
                        value: (width * (quantityFloat - 1)) / quantityFloat / 2,
                        format: numberFormat
                    ),
                    .attribute(
                        named: "y",
                        value: options.beamHeight + 16,
                        format: numberFormat
                    ),
                    .attribute(named: "font-size", value: "14"),
                    .attribute(named: "text-anchor", value: "middle"),
                    .attribute(named: "font-family", value: "sans-serif"),
                    .attribute(named: "fill", value: fill),
                ]
            )
            
//            textEl.setAttributeNS(
//                null,
//                "x",
//                ((width * (quantity - 1)) / quantity / 2).toString()
//            );
//            textEl.setAttributeNS(null, "y", (beamHeight + 16).toString());
//            textEl.setAttributeNS(null, "font-size", "14");
//            textEl.setAttributeNS(null, "text-anchor", "middle");
//            textEl.setAttributeNS(null, "font-family", "sans-serif");
//            textEl.setAttributeNS(null, "fill", fill);
            
//            const textContent = document.createTextNode(subtitle);
//            textEl.appendChild(textContent);
            
//            gEl.appendChild(textEl);
        } else {
            textEl = nil
        }
        
        let stemLines = (0..<quantity).map { i in
            Node<SVG.DocumentContext>.element(
                named: "rect",
                attributes: [
                    .attribute(
                        named: "width",
                        value: options.beamStrokeWidth,
                        format: numberFormat
                    ),
                    .attribute(named: "height", value: options.beamHeight, format: numberFormat),
                    .attribute(named: "fill", value: fill),
                    .attribute(
                        named: "x",
                        value: (width * CGFloat(i)) / quantityFloat - options.beamStrokeWidth / 2,
                        format: numberFormat
                    ),
                ]
            )
        }
        
        let stemBeams = (0..<horizontalStrokes).map { i in
            Node<SVG.DocumentContext>.element(
                named: "rect",
                attributes: [
                    .attribute(
                        named: "width",
                        value: (width * (quantityFloat - 1)) / quantityFloat + options.beamStrokeWidth,
                        format: numberFormat
                    ),
                    .attribute(
                        named: "height",
                        value: options.beamStrokeWidth / CGFloat(horizontalStrokes),
                        format: numberFormat
                    ),
                    .attribute(named: "fill", value: fill),
                    .attribute(
                        named: "x",
                        value: -options.beamStrokeWidth / 2,
                        format: numberFormat
                    ),
                    .attribute(
                        named: "y",
                        value: options.beamHeight - CGFloat(i) * options.beamStrokeWidth,
                        format: numberFormat
                    ),
                ] as [Attribute<XML.DocumentContext>]
            )
        }

        
        return Node<SVG.DocumentContext>.element(
            named: "g",
            nodes: [
                [.attribute(
                    named: "transform",
                    value: "translate(\(x.formatted(numberFormat)),\(y.formatted(numberFormat)))"
                )],
                stemLines,
                stemBeams,
                [textEl]
                    .compactMap { $0 },
            ].flatMap { $0 }
        )
    }
}
