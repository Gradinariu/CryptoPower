//
//  CryptoAPICoin+Extensions.swift
//  CryptoPower
//
//  Created by Cezar Gradinariu on 19.08.2024.
//

import CryptoAPI
import RealmSwift

extension CryptoAPI.Coin {
    func getRealmModel() -> RealmCoin {
        let realmCoin = RealmCoin()
        realmCoin.code = self.code
        realmCoin.name = self.name
        realmCoin.currentPrice = self.price
        realmCoin.min = self.price
        realmCoin.max = self.price
        realmCoin.imageUrl = self.imageUrl ?? ""
        return realmCoin
    }
}
