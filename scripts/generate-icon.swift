import AppKit
import Foundation

let arguments = CommandLine.arguments
guard arguments.count == 2 else {
    fputs("Usage: swift scripts/generate-icon.swift <output-iconset>\n", stderr)
    exit(2)
}

let outputURL = URL(fileURLWithPath: arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

let sizes: [(filename: String, pixels: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

func drawIcon(pixels: Int) throws -> Data {
    let size = NSSize(width: pixels, height: pixels)
    let image = NSImage(size: size)
    image.lockFocus()

    let rect = NSRect(origin: .zero, size: size)
    let corner = CGFloat(pixels) * 0.22
    let background = NSBezierPath(roundedRect: rect.insetBy(dx: 1, dy: 1), xRadius: corner, yRadius: corner)
    NSColor(calibratedRed: 0.025, green: 0.085, blue: 0.12, alpha: 1).setFill()
    background.fill()

    let scale = CGFloat(pixels)
    let island = NSBezierPath()
    island.move(to: NSPoint(x: scale * 0.18, y: scale * 0.41))
    island.curve(
        to: NSPoint(x: scale * 0.82, y: scale * 0.41),
        controlPoint1: NSPoint(x: scale * 0.29, y: scale * 0.66),
        controlPoint2: NSPoint(x: scale * 0.71, y: scale * 0.66)
    )
    island.curve(
        to: NSPoint(x: scale * 0.18, y: scale * 0.41),
        controlPoint1: NSPoint(x: scale * 0.70, y: scale * 0.30),
        controlPoint2: NSPoint(x: scale * 0.30, y: scale * 0.30)
    )
    island.close()
    NSColor(calibratedRed: 0.31, green: 0.91, blue: 0.72, alpha: 1).setFill()
    island.fill()

    for offset in [0.25, 0.15] {
        let wave = NSBezierPath()
        wave.lineWidth = max(2, scale * 0.045)
        wave.lineCapStyle = .round
        wave.move(to: NSPoint(x: scale * 0.21, y: scale * offset))
        wave.curve(
            to: NSPoint(x: scale * 0.79, y: scale * offset),
            controlPoint1: NSPoint(x: scale * 0.36, y: scale * (offset + 0.08)),
            controlPoint2: NSPoint(x: scale * 0.64, y: scale * (offset - 0.08))
        )
        NSColor(calibratedRed: 0.35, green: 0.72, blue: 0.96, alpha: 1).setStroke()
        wave.stroke()
    }

    image.unlockFocus()
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        throw CocoaError(.fileWriteUnknown)
    }
    return png
}

for item in sizes {
    let data = try drawIcon(pixels: item.pixels)
    try data.write(to: outputURL.appendingPathComponent(item.filename))
}
