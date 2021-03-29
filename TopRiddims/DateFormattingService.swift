//
//  DateFormattingService.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/30/21.
//

import Foundation

struct CustomDateFormatter{
    
    static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .none
        df.dateStyle = .short
        return df
    }()
    
}
