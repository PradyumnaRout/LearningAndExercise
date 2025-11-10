//
//  HomeAPIService.swift
//  BookXPAssign
//
//  Created by Pradyumna Rout on 21/06/25.
//

import Foundation

class HomeAPIService {
    
    // Fetch Data Form API
    func fetchData(with urlString: String) async -> [PortfolioData] {
        guard let url = URL(string: urlString) else { return [] }
        
        do  {
            let response: [PortfolioData] = try await NetworkManager.dataRequest(with: url)
            return response
        } catch {
            print("Erro :: \(error.localizedDescription)")
            return []
        }
    }
}
