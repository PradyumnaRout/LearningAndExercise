//
//  HomeViewModel.swift
//  BookXPAssign
//
//  Created by Pradyumna Rout on 21/06/25.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties (UI State)
    @Published var listData: [PortfolioData] = []
    @Published var selectedDevice: PortfolioData?
    @Published var name: String = ""
    @Published var color: String = ""
    @Published var memory: String = ""
    @Published var price: String = ""
    @Published var errorTextType: TextFieldType = .non
    @Published var isLoading: Bool = false

    // MARK: - Private Properties
    private var homeService: HomeAPIService
    
    var tasks: [Task<(), Never>] = []
    
    // MARK: - Initializer & Deinitializer
    init() {
        homeService = HomeAPIService()
        fetchListData()
    }
    
    deinit { tasks.forEach({ $0.cancel() })}
    
    // Data Extraction for Editing
    func extractEditableData() {
        guard let selectedDevice = selectedDevice else { return }
        name = selectedDevice.name ?? ""
        color = selectedDevice.data?.color ?? ""
        memory = selectedDevice.data?.capacity ?? ""
        price = String(selectedDevice.data?.price ?? 0.0) == "0.0" ? "" : String(selectedDevice.data?.price ?? 0.0)
    }
    
    // Loads and decodes a JSON file from the app bundle.
    func load<T: Decodable>(_ filename: String) -> T {
        let data: Data
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
    
    // Fetches the portfolio list from Core Data.
    private func fetchListFromDb() {
        let task = Task {
            let storedData = await CoreDataManager.shared.fetchPortfolios()
            listData = storedData
            isLoading = false
        }
        tasks.append(task)
    }
    
    // Fetches the portfolio list from Core Data and updates the UI.
    private func fetchListData() {
        
        isLoading = true
        let task = Task {
            // Online
            let fetchedData = await homeService.fetchData(with: AppConstants.dataUrl)
            
            // Offline
//            let fetchedData: [PortfolioData] = load("Response.json")
            await CoreDataManager.shared.deleteAllPortfolios()
            await CoreDataManager.shared.persistPortfolio(from: fetchedData)
            fetchListFromDb()
            debugPrint(listData.first?.name ?? "")
        }
        tasks.append(task)
    }
    
    // Delete Item by ID
    func deleteItem(_ id: String, _ item: PortfolioData) {
        let task = Task {
            await CoreDataManager.shared.deletePortfolio(id: id)
            fetchListFromDb()
        }
        tasks.append(task)
    }
    
    // Updates the currently selected device with the edited fields and saves to Core Data
    func updateItem() {
        guard let item = selectedDevice else {
            return
        }
        let priceInDouble = Double(price)
        var updateItem = item
        updateItem.name = name
        
        if updateItem.data == nil {
            updateItem.data = DeviceData(color: color, capacity: memory, price: priceInDouble)
        } else {
            updateItem.data?.color = color
            updateItem.data?.price = priceInDouble
            updateItem.data?.capacity = memory
        }
        
        let task = Task {
            let success = await CoreDataManager.shared.updatePortfolio(with: updateItem)
            print("Successfully Updated")
            if success {
                fetchListFromDb()
            }
        }
        tasks.append(task)
    }
    
    /// Validations
    func validateFields() {
        
        if price.isEmpty {
            errorTextType = .price
            print("Price is empty")
        }
        if memory.isEmpty {
            errorTextType = .memory
            print("memory is empty")
        }
        if color.isEmpty {
            errorTextType = .color
            print("color is empty")
        }
    }
}

enum TextFieldType: String {
    case non
    case price = "price"
    case memory = "memory"
    case color = "color"
}
