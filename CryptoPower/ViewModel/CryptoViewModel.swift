//
//  CryptoManager.swift
//  CryptoPower
//
//  Created by Cezar Gradinariu on 16.08.2024.
//

import CryptoAPI
import RealmSwift
import SwiftUI

class CryptoViewModel: ObservableObject, CryptoDelegate {
        
    private var cryptoAPI: Crypto?
    private let realm = try! Realm()
    
    @Published var coinGoesUp: RealmCoin?
    @Published var coinGoesDown: RealmCoin?


    
    init() {
        self.cryptoAPI = Crypto(delegate: self)
    }
    
    private(set) var connectionStatus = false
    
    func cryptoAPIDidConnect() {
        print("intru in did connect")
        connectionStatus = true
    }
    
    func cryptoAPIDidUpdateCoin(_ coin: CryptoAPI.Coin) {
        DispatchQueue.main.async {
            print("Crypto did update coin: \(coin)")
            self.updateCoinPrice(coin)
            let allCoins = self.realm.objects(RealmCoin.self)
            guard let coinRealm = allCoins.filter("code == %@", coin.code).first else {
                return
            }
            let priceHistory = coinRealm.priceHistory
            
            var oneBeforeLastPrice: Double? = nil
            print("price history array: \(priceHistory.elements)")
            if priceHistory.elements.count > 1 {
                let lastIndex = priceHistory.count - 1
                oneBeforeLastPrice = priceHistory[lastIndex - 1]
            } else {
                print("Array does not have enough items")
            }
            if let oneBeforeLastPrice {
                    if coinRealm.currentPrice > oneBeforeLastPrice {
                        self.coinGoesUp = coinRealm
                    } else if coinRealm.currentPrice < oneBeforeLastPrice {
                        self.coinGoesDown = coinRealm
                    }
            }
        }
    }
    
    func cryptoAPIDidDisconnect() {
        print("CryptoAPI did disconnect.")
        connectionStatus = false

    }
    
    func connect() {
        if connectionStatus == false {
            let result = cryptoAPI?.connect()
            switch result {
            case .success(let isConnected):
                if isConnected {
                    connectionStatus = true
                } else {
                    print("Didn't connect to CryptoAPI")
                }
            case .failure(let error):
                print("Failed to connect co CryptoAPI. Error: \(error)")
            case .none:
                print("Failed to connect. None case")
            }
        }
    }
    
    func disconnect() {
        if connectionStatus == true {
            cryptoAPI?.disconnect()
        }
    }
    
    func getAllCoins() {
        if connectionStatus == true {
            guard let cryptoAPI else {
                return
            }
            let cryptoCoins = cryptoAPI.getAllCoins()
            for cryptoCoin in cryptoCoins {
                updateCoinPrice(cryptoCoin)
            }
        }
    }
    
    private func updateCoinPrice(_ coin: CryptoAPI.Coin) {
        DispatchQueue.main.async {
            do {
                try self.realm.write {
                    // Fetch or create a CoinPrice object for the coin
                    var coinPrice = self.realm.object(ofType: RealmCoin.self, forPrimaryKey: coin.code)
                    if coinPrice == nil {
                        coinPrice = coin.getRealmModel()
                        self.realm.add(coinPrice!, update: .all)
                    } else {
                        print("Update the current price: \(coinPrice)")
                        // Update the current price
                        if let coinPrice {
                            coinPrice.currentPrice = coin.price
                            coinPrice.min = min(coinPrice.priceHistory.min() ?? Double.greatestFiniteMagnitude, coin.price)
                            coinPrice.max = max(coinPrice.priceHistory.max() ?? Double.leastNonzeroMagnitude, coin.price)
                        }
                    }
                    // Add the new price entry to the price history
                    coinPrice?.priceHistory.append(coin.price)
                }
            } catch {
                print("Error updating coin price in Realm: \(error)")
            }
        }
    }
}
