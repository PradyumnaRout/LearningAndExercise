//
//  ProtfolioData.swift
//  BookXPAssign
//
//  Created by Pradyumna Rout on 21/06/25.
//

import Foundation

import Foundation

import Foundation

// MARK: - PortfolioData
struct PortfolioData: Codable {
    let id: String?
    var name: String?
    var data: DeviceData?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        data = try container.decodeIfPresent(DeviceData.self, forKey: .data)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(data, forKey: .data)
    }
}
//
//
struct DeviceData: Codable {
    var color: String?
    var capacity: String?
    var price: Double?
    let generation: String?
    let year: Int?
    let cpuModel: String?
    let hardDiskSize: String?
    let strapColour: String?
    let caseSize: String?
    let description: String?
    let screenSize: Double?

    enum CodingKeys: String, CodingKey {
        case color
        case Color
        case capacity
        case Capacity
        case capacityGB = "capacity GB"
        case price
        case Price
        case generation
        case year
        case cpuModel = "CPU model"
        case hardDiskSize = "Hard disk size"
        case strapColour = "Strap Colour"
        case caseSize = "Case Size"
        case description
        case screenSize = "Screen size"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // color / Color
        var colorValue: String? = try container.decodeIfPresent(String.self, forKey: .color)
        if colorValue == nil {
            colorValue = try? container.decodeIfPresent(String.self, forKey: .Color)
        }
        if colorValue == nil {
            colorValue = try? container.decodeIfPresent(String.self, forKey: .strapColour)
        }
        color = colorValue

        // capacity / Capacity / capacity GB
        var capacityValue: String? = try container.decodeIfPresent(String.self, forKey: .capacity)
        if capacityValue == nil {
            capacityValue = try? container.decodeIfPresent(String.self, forKey: .Capacity)
        }
        if capacityValue == nil {
            // Try capacity GB as Int
            if let gb = try? container.decodeIfPresent(Int.self, forKey: .capacityGB) {
                capacityValue = "\(gb) GB"
            }
        }
        capacity = capacityValue

        // price / Price
        if let priceDouble = try? container.decodeIfPresent(Double.self, forKey: .price) {
            price = priceDouble
            debugPrint("Price in Double Format \(priceDouble)")
        } else if let priceString = try? container.decodeIfPresent(String.self, forKey: .Price),
                  let priceDouble = Double(priceString) {
            debugPrint("Price in String Format \(priceDouble)")
            price = priceDouble
        } else {
            price = nil
        }
        
        // generation / Generation
        var generationValue: String? = try container.decodeIfPresent(String.self, forKey: .generation)
        if generationValue == nil, let generationKey = CodingKeys(stringValue: "Generation") {
            generationValue = try? container.decodeIfPresent(String.self, forKey: generationKey)
        }
        generation = generationValue

        year = try container.decodeIfPresent(Int.self, forKey: .year)
        cpuModel = try container.decodeIfPresent(String.self, forKey: .cpuModel)
        hardDiskSize = try container.decodeIfPresent(String.self, forKey: .hardDiskSize)
        strapColour = try container.decodeIfPresent(String.self, forKey: .strapColour)
        caseSize = try container.decodeIfPresent(String.self, forKey: .caseSize)

        // description / Description
        var descriptionValue: String? = try container.decodeIfPresent(String.self, forKey: .description)
        if descriptionValue == nil, let descriptionKey = CodingKeys(stringValue: "Description") {
            descriptionValue = try? container.decodeIfPresent(String.self, forKey: descriptionKey)
        }
        description = descriptionValue

        screenSize = try container.decodeIfPresent(Double.self, forKey: .screenSize)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encodeIfPresent(capacity, forKey: .capacity)
        try container.encodeIfPresent(price, forKey: .price)
        try container.encodeIfPresent(generation, forKey: .generation)
        try container.encodeIfPresent(year, forKey: .year)
        try container.encodeIfPresent(cpuModel, forKey: .cpuModel)
        try container.encodeIfPresent(hardDiskSize, forKey: .hardDiskSize)
        try container.encodeIfPresent(strapColour, forKey: .strapColour)
        try container.encodeIfPresent(caseSize, forKey: .caseSize)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(screenSize, forKey: .screenSize)
    }
}


extension PortfolioData {
    
    init(device: Device) {
        self.id = device.id
        self.name = device.name
        self.data = DeviceData(device: device)
    }
    
}

extension DeviceData {
    
    init?(device: Device) {
        guard let detailData = device.detailData else { return nil }
        guard let decoded = try? JSONDecoder().decode(DeviceData.self, from: detailData) else { return nil }
        self = decoded
    }
    
    init(color: String, capacity: String, price: Double?) {
        self.color = color
        self.capacity = capacity
        self.price = price
        self.generation = nil
        self.year = nil
        self.cpuModel = nil
        self.hardDiskSize = nil
        self.strapColour = nil
        self.caseSize = nil
        self.description = nil
        self.screenSize = nil
    }
    
}

