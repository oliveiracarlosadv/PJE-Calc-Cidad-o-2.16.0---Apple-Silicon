// Gera o ícone "PJe" (1024x1024 PNG). Uso: swift gerar-icone.swift saida.png
import AppKit
let size: CGFloat = 1024
let out = CommandLine.arguments[1]
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let inset: CGFloat = 100
let rect = NSRect(x: inset, y: inset, width: size - 2*inset, height: size - 2*inset)
let path = NSBezierPath(roundedRect: rect, xRadius: 185, yRadius: 185)
let sh = NSShadow(); sh.shadowColor = NSColor(white: 0, alpha: 0.35); sh.shadowBlurRadius = 24; sh.shadowOffset = NSSize(width: 0, height: -10); sh.set()
NSColor(red: 0.27, green: 0.42, blue: 0.60, alpha: 1).setFill(); path.fill()
NSShadow().set()
let grad = NSGradient(starting: NSColor(red: 0.42, green: 0.58, blue: 0.76, alpha: 1), ending: NSColor(red: 0.18, green: 0.31, blue: 0.48, alpha: 1))!
grad.draw(in: path, angle: -90)
let para = NSMutableParagraphStyle(); para.alignment = .center
let font = NSFont(name: "Avenir Next Heavy", size: 330) ?? NSFont.boldSystemFont(ofSize: 330)
let tsh = NSShadow(); tsh.shadowColor = NSColor(white: 0, alpha: 0.3); tsh.shadowBlurRadius = 10; tsh.shadowOffset = NSSize(width: 0, height: -6)
let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.white, .paragraphStyle: para, .shadow: tsh]
let s = NSAttributedString(string: "PJe", attributes: attrs)
let h = s.size().height
s.draw(in: NSRect(x: inset, y: (size - h)/2 - 10, width: size - 2*inset, height: h))
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
