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
            if i == self.listData.data.count - 1 {
                cellView(data: self.listData.data[i], isLast: true, listData: self.listData)
            } else {
                cellView(data: self.listData.data[i], isLast: false, listData: self.listData)
            }

        }
    }
}

struct cellView: View {
    
    var data: Doc
    var isLast: Bool
    @ObservedObject var listData: getData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(data.id).fontWeight(.bold)
            Text(data.eissn)
            Text(data.article_type)
            
            if self.isLast {
                Text(data.publication_date).font(.caption)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if self.listData.data.count != 50 {
                                self.listData.updateData()
                            }
                        }
                    }
            } else {
                Text(data.publication_date)
            }
            
        }
        .padding(.top, 10)
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
                    self.count += 10
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
