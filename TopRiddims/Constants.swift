//
//  Constants.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/17/21.
//

import UIKit

struct K{
    
    static let videoWidthMultiplier: CGFloat = 0.8
    
    static let chartCellAdditionalHeight: CGFloat = 100
    static let chartCellHeaderHeight: CGFloat = 40
    static let chartCellFooterHeight: CGFloat = 180
    
    static let ChartCollectionFooterPlusPointSize: CGFloat = 100
    static let VideoCollectionViewEdgeInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    
    static let videoCollectionViewCellExtraHeight: CGFloat = 50
    
    enum Country: String, Equatable{
        case jamaica = "0x8eda2a1bc6cf719d%3A0x59a0d1c0b5120efa"
        case trini = "0x8c3607976350b6c5%3A0xff082855c639f127"
        case haiti = "0x8eb6c6f37fcbbb11%3A0xb51438b24c54f6d3"
        case barbados = "0x8c43f1fbae321aa3%3A0xeec51b38cf4362b"
        case puerto = "0x8c0296261b92a7f9%3A0xf336ec2818049b1a"
        
        
        var name: String{
            switch self{
            case .jamaica: return "Jamaica"
            case .trini: return "Trinidad & Tobago"
            case .haiti: return "Haiti"
            case .barbados: return "Barbados"
            case .puerto: return "Puerto Rico"
            }
        }
        init(countryname: String) {
            switch countryname{
            case "Jamaica":
                guard let country = Country(rawValue: "0x8eda2a1bc6cf719d%3A0x59a0d1c0b5120efa") else{preconditionFailure("Company is undefined.")}
                self = country
            case "Trinidad & Tobago":
                guard let country = Country(rawValue: "0x8c3607976350b6c5%3A0xff082855c639f127") else{preconditionFailure("Company is undefined.")}
                self = country
            case "Haiti":
                guard let country = Country(rawValue: "0x8eb6c6f37fcbbb11%3A0xb51438b24c54f6d3") else{preconditionFailure("Company is undefined.")}
                self = country
            case "Barbados":
                guard let country = Country(rawValue: "0x8c43f1fbae321aa3%3A0xeec51b38cf4362b") else{preconditionFailure("Company is undefined.")}
                self = country
            case "Puerto Rico":
                guard let country = Country(rawValue: "0x8c0296261b92a7f9%3A0xf336ec2818049b1a") else{preconditionFailure("Company is undefined.")}
                self = country
            default:
                preconditionFailure("Company is undefined.")
            }
        }
        
    }
    
    
    
    
    
}
