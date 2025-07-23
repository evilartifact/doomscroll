//
//  TimeInterval+Extensions.swift
//  doomscrollReportExtension
//
//  Created by Rabin on 7/22/25.
//

import Foundation
import os.log

extension TimeInterval {
    private static let logger = Logger(subsystem: "llc.doomscroll.doomscrollReportExtension", category: "TimeInterval+Extensions")
    
    func toString() -> String {
        TimeInterval.logger.info("📊 Converting TimeInterval to string: \(self) seconds")
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        let result = formatter.string(from: self) ?? "0:00"
        TimeInterval.logger.info("📊 Formatted result: \(result)")
        return result
    }
    
    func toScreenTimeString() -> String {
        TimeInterval.logger.info("📊 Converting TimeInterval to screen time string: \(self) seconds")
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        
        let result = formatter.string(from: self) ?? "0s"
        TimeInterval.logger.info("📊 Formatted screen time result: \(result)")
        return result
    }
}
