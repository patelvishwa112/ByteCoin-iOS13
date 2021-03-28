//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didGetExchangeRate(price: String, currency: String)
    
    func didFailedWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "YOUR_API_KEY_HERE"
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String) {
        // Set fiatCurrency as String
        
        let finalString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        // 1. Create a URL
        if let url = URL(string: finalString){
            
            // 2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task = session.dataTask(with: url) {
                (data, response, error) in
                if error != nil{
                    print(error!) // Force-unwrap the error
                    self.delegate?.didFailedWithError(error: error!)
                    return
                }
                
                // Unwrap the data and if it exists,
                if let safeData = data {
                    if let bitcoinPrice = self.parseJSON(safeData){
                        
                        let lastPrice = String(format: "%.4f", bitcoinPrice)
                        
                        self.delegate?.didGetExchangeRate(price: lastPrice, currency: currency)
                    }
                }
                
            }
            //4. Start the task
            task.resume()
        }
    }
    
    
    func parseJSON(_ cryptoData: Data) -> Double? {
        let decoder = JSONDecoder()
        
        do{
            //Parse Raw API Response in JSON Format
            let decoderData = try decoder.decode(CoinData.self, from: cryptoData)
            
            // Extract Values from JSON and initialize a model class
            let rate = decoderData.rate  // String(format: "%.4f" , decoderData.rate)
//            print("The rate of BTC is \(rate)")
            
            // Return value in String format
            return rate
            
        }
        catch{
            print(error)
            delegate?.didFailedWithError(error: error)
            return nil
        }
    }
}


