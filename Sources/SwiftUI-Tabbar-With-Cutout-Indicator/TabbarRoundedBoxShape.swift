//
//  TabbarRoundedBoxShape.swift
//  SwiftUI-Tabbar-With-Cutout-Indicator
//
//  Created by acumenrev on 2/1/26.
//

import SwiftUI

struct TabBarRoundedBoxShape: Shape {
    var gapRatio: CGFloat = 0.6
    // New parameter to control how round the corners are
    var topCornerRadius: CGFloat = 12
    var botCornerRadius: CGFloat = 12
    
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        // Ensure height is at least 2x radius so corners don't overlap
        let height = max(rect.height, topCornerRadius * 2)
        
        // Calculate X positions for the left and right sides of the dip
        let shoulderWidth = (width * (1.0 - gapRatio)) / 2
        let dipLeftX = shoulderWidth
        let dipRightX = width - shoulderWidth
        
        // 1. Start Top Left
        path.move(to: CGPoint(x: 0, y: 0))
        
        // 2. Line along left shoulder to where the curve starts
        path.addLine(to: CGPoint(x: dipLeftX - topCornerRadius, y: 0))
        
        // --- The Dip ---
        
        // 3. Top-Left corner (curving down into the dip)
        // tangent1 defines the corner point, tangent2 defines the direction after the turn
        path.addArc(tangent1End: CGPoint(x: dipLeftX, y: 0),
                    tangent2End: CGPoint(x: dipLeftX, y: height),
                    radius: topCornerRadius)
        
        // 4. Bottom-Left corner (curving right along the bottom)
        // Note: addArc automatically draws the straight line down connecting the previous arc
        path.addArc(tangent1End: CGPoint(x: dipLeftX, y: height),
                    tangent2End: CGPoint(x: dipRightX, y: height),
                    radius: botCornerRadius)
        
        // 5. Bottom-Right corner (curving up out of the bottom)
        path.addArc(tangent1End: CGPoint(x: dipRightX, y: height),
                    tangent2End: CGPoint(x: dipRightX, y: 0),
                    radius: botCornerRadius)
        
        // 6. Top-Right corner (curving right onto the shoulder)
        path.addArc(tangent1End: CGPoint(x: dipRightX, y: 0),
                    tangent2End: CGPoint(x: width, y: 0),
                    radius: topCornerRadius)
        
        // --- End Dip ---
        
        // 7. Finish right shoulder
        path.addLine(to: CGPoint(x: width, y: 0))
        
        // --- The "Eraser Lid" ---
        // Crucial for .destinationOut to work cleanly on the top edge
        path.addLine(to: CGPoint(x: width, y: -30))
        path.addLine(to: CGPoint(x: 0, y: -30))
        path.closeSubpath()
        
        return path
    }
}
