//
//  Color.swift
//  SpiceCompanion
//
//  Created by marika on 2022-10-04.
//

import SwiftUI

extension Color {

    /// Get this color with the given adjustements.
    /// - Parameter hue: The percentage to adjust the hue by.
    /// - Parameter saturation: The percentage to adjust the saturation by.
    /// - Parameter brightness: The percentage to adjust the brightness by.
    /// - Parameter alpha: The percentage to adjust the alpha by.
    /// - Returns: The new adjusted color.
    func adjust(hue: CGFloat = 1.0, saturation: CGFloat = 1.0, brightness: CGFloat = 1.0, alpha: CGFloat = 1.0) -> Color {
        let uiColor = UIColor(self)
        var h = CGFloat(0)
        var s = CGFloat(0)
        var b = CGFloat(0)
        var a = CGFloat(0)
        guard uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            return self
        }

        h = adjustPercentage(h, by: hue)
        s = adjustPercentage(s, by: saturation)
        b = adjustPercentage(b, by: brightness)
        a = adjustPercentage(a, by: alpha)
        return Color(uiColor: UIColor(hue: h, saturation: s, brightness: b, alpha: a))
    }

    /// Adjust the given percentage by the given percentage of said percentage.
    /// - Parameter value: The percentage to adjust.
    /// - Parameter adjustment: The percentage of the given value to adjust it by.
    /// - Returns: The adjusted percentage, from `0.0` to `1.0`.
    private func adjustPercentage(_ value: CGFloat, by adjustment: CGFloat) -> CGFloat {
        return min(max(value + (adjustment * value), 0.0), 1.0)
    }
}
