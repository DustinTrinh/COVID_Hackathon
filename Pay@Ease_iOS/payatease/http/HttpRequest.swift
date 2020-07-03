//
//  HttpRequest.swift
//  payatease
//
//  Created by Andy Lin on 2020-06-30.
//  Copyright © 2020 Andy Lin. All rights reserved.
//

import Foundation


enum APIError: Error {
    case responseError
    case otherError
}

class HttpRequest {
    
    let apiKey = "https://payatease.herokuapp.com/api/"
    let username :String
    let password :String
    //create the session object
    let session = URLSession.shared
    
    init(username: String, password: String) {
        
        self.username = username
        self.password = password
        
        
    }
    
    // GET request to get all infomation about user
    func getUser(completion: @escaping (Result<User,Error>) -> Void) {
        
        //create the url with NSURL
        let url = URL(string: "\(apiKey)account/detail/\(username)/")!
        
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
                print(user)
            } catch let error {
                completion(.failure(error))
                print(error.localizedDescription)
            }
        })
        
        task.resume()
        
        
    }
    
    
    // PUT request for paying a bill
    func payBill(payment: Payment, completion: @escaping (Result<Bill,APIError>) -> Void) {
        //create the url with NSURL
        let url = URL(string: "\(apiKey)account/detail/\(username)/")!
        
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        do {
            print(payment)
            request.httpBody = try JSONEncoder().encode(payment)
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                guard error == nil else {
                    completion(.failure(.otherError))
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any] {
                        print(json)
                    }
                } catch {
                    
                }
                
                guard let jsonData = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(.responseError))
                    return
                }
                
                do {
                    let bill = try JSONDecoder().decode(Bill.self, from: jsonData)
                    completion(.success(bill))
                    print("Success")
                } catch let error {
                    completion(.failure(.responseError))
                    print(error.localizedDescription)
                }
            })
            
            task.resume()
        } catch let error {
            print(error)
        }
        
        
        
        
    }
    
    
    
    
    
}
