//
//  ContentView.swift
//  InfiniteScroll
//
//  Created by JeongminKim on 2021/11/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            Home()
                .navigationTitle("Home")
        }
        
    }
}

struct Home: View {
    @ObservedObject var listData = getData()
    var body: some View {
        List(0..<listData.data.count, id: \.self) { i in
            Text(self.listData.data[i].id)
        }
    }
}

class getData: ObservableObject {
    @Published var data = [Doc]()
    @Published var count = 1
    
    init() {
        updateData()
    }
    
    func updateData() {
        let url = "https://api.plos.org/search?q=title:%22Food%22&start=\(count)&rows=10"
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: URL(string: url)!) { data, response, err in
            
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            
            do {
                let json = try JSONDecoder().decode(Detail.self, from: data!)
                let oldData = self.data
                DispatchQueue.main.async {
                    self.data = oldData + json.response.docs
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

struct Detail: Decodable {
    var response: Response
}

struct Response: Decodable {
    var docs: [Doc]
}

struct Doc: Decodable {
    var id: String
    var eissn: String
    var publication_date: String
    var article_type: String
}
