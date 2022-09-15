//
//  VMDisplay.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/13.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import AppKit
import Foundation

struct VMDisplay: Hashable, Equatable, Codable, CustomStringConvertible, Identifiable {
    var name: String
    var width: Int
    var height: Int
    var pixelsPerInch: Int = defaultPPI

    var description: String {
        "\(width)x\(height)"
    }

    var id: String {
        "\(name) \(width)x\(height) \(pixelsPerInch)"
    }

    static var defaultPPI: Int {
        guard let screen = NSScreen.main, let resolution = screen.deviceDescription[.resolution] as? NSSize else {
            return 144
        }
        return Int(resolution.width)
    }
}

// MARK: Presets

extension VMDisplay {
    static let `default` = VMDisplay(name: "Full HD", width: 1920, height: 1080)

    static var presets: [Self] {
        [
            VMDisplay(name: "HD 1280x720", width: 1280, height: 720),
            VMDisplay(name: "WXGA 1280x800", width: 1280, height: 800),
            VMDisplay(name: "Full HD 1920x1080", width: 1920, height: 1080),
            VMDisplay(name: "2K 2560x1440", width: 2560, height: 1440),
            VMDisplay(name: "4K 3840x2160", width: 3840, height: 2160, pixelsPerInch: 218),
            VMDisplay(name: "5K 5120x2880", width: 5120, height: 2880),
        ] + presetsFromDevice
    }

    static var presetsFromDevice: [Self] {
        var presets = [Self]()

        NSScreen.screens.forEach { screen in
            guard let size = screen.deviceDescription[.size] as? NSSize,
                  let resolution = screen.deviceDescription[.resolution] as? NSSize
            else {
                return
            }
            let display = VMDisplay(
                name: screen.localizedName,
                width: Int(size.width),
                height: Int(size.height),
                pixelsPerInch: Int(resolution.width)
            )
            presets.append(display)
        }

        return presets
    }
}
