//
//  CoinsViewModel.swift
//  NetworkingTutorial
//
//  Created by Kailash Bora on 16/11/23.
//

import Foundation
import UIKit
import Swift

class CoinsViewModel: ObservableObject {
    @Published var coins = [Coin]()
    @Published var errorMessage: String?
    
    let service = CoinsService() /// Service class will be now responsible for the communication with the API and provide data to ViewModel. 

    init() {
        /// Task is used so that we don't have to make each any every method async whenever an await method is called inside it.
        Task { try await fetchCoinsWithAsync()}
    }

    func fetchCoinsWithAsync() async throws {
        let fetchedCoins = try await service.fetchCoins()
        DispatchQueue.main.async {
            self.coins = fetchedCoins
        }
    }
    
    func fetchCoinsWithResult() {
        /// We are going to use "weak self" inside a closure to avoid strong refrence and make our process more smoother.
        /// Keeping a strong refrence even though the view is killed, will make the app freeze.
        service.fetchCoinsWithResult { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let coins):
                    self?.coins = coins /// Since we are using weak self we have to use optional chaining. 
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
