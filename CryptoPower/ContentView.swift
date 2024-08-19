//
//  ContentView.swift
//  CryptoPower
//
//  Created by Cezar Gradinariu on 16.08.2024.
//

import CryptoAPI
import RealmSwift
import SwiftUI

struct ContentView: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject private var cryptoViewModel = CryptoViewModel()
    
    @ObservedResults(RealmCoin.self) var cryptoCoins
    
    var body: some View {
        NavigationView {
            VStack {
                List(cryptoCoins, id: \.name) { coin in
                    coinInList(coin: coin)
                }
                .listStyle(.plain)
            }
            .navigationBarTitle(Text("Market"), displayMode: .large)
            
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .inactive:
                applicationWillResignActive()
            case .active:
                applicationDidBecomeActive()
                getAllCoins()
            case .background:
                applicationWillResignActive()
            @unknown default:
                return
            }
        }
    }
    
    private func coinInList(coin: RealmCoin) -> some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: URL(string: coin.imageUrl)) { image in
                image.image?.resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .onAppear {
                        print(coin.imageUrl)
                    }
            }
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 32) {
                    HStack(spacing: 10) {
                        Text(coin.name)
                            .font(.system(size: 16))
                        Text(coin.code)
                            .opacity(0.6)
                        Spacer()
                        
                    }
                    HStack(spacing: 32) {
                        HStack(spacing: 2) {
                            Text("min:")
                                .font(.system(size: 12))
                                .opacity(0.6)
                            
                            Text("$ " + String(format: coin.min > 1 ? "%.2f" : "%.6f", coin.min))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                                .font(.system(size: 12))
                        }
                        
                        HStack(spacing: 2) {
                            Text("max:")
                                .font(.system(size: 12))
                                .opacity(0.6)
                            
                            Text("$ " + String(format: coin.max > 1 ? "%.2f" : "%.6f", coin.max))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                                .font(.system(size: 12))
                        }
                    }
                }
                Text("$ " + String(format: coin.currentPrice > 1 ? "%.2f" : "%.6f", coin.currentPrice))
                    .foregroundColor(((coin.code == cryptoViewModel.coinGoesUp?.code) ||
                                     (coin.code == cryptoViewModel.coinGoesDown?.code)) ?
                                     Color.white : Color.black)
                    .padding(8)
                    .background(cryptoViewModel.coinGoesUp?.code == coin.code ? Color.green : Color.clear)
                    .background(cryptoViewModel.coinGoesDown?.code == coin.code ? Color.red : Color.clear)
                    .cornerRadius(4)
                    .animation(.easeInOut(duration: 0.5), value: coin.currentPrice)

            }
        }
    }
    
    private func applicationDidBecomeActive() {
        cryptoViewModel.connect()
    }
    
    private func applicationWillResignActive() {
        cryptoViewModel.disconnect()
    }
    
    private func getAllCoins() {
        cryptoViewModel.getAllCoins()
    }
}

#Preview {
    ContentView()
}
