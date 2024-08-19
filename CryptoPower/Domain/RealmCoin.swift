//
//  RealmCoin.swift
//  CryptoPower
//
//  Created by Cezar Gradinariu on 19.08.2024.
//

import RealmSwift

class RealmCoin: Object, Identifiable {
    @Persisted(primaryKey: true) var code: String
    @Persisted var name: String
    @Persisted var min: Double
    @Persisted var max: Double
    @Persisted var currentPrice: Double
    @Persisted var priceHistory: List<Double>
    @Persisted var imageUrl: String

}
