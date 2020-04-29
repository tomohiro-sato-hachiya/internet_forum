//
//  InternetForumView.swift
//  InternetForumiOS
//
//  Created by 佐藤智宏 on 2020/04/29.
//  Copyright © 2020 佐藤智宏. All rights reserved.
//

import SwiftUI

struct InternetForumView: View {
    @ObservedObject var namedSpeaksModel:NamedSpeaksModel = NamedSpeaksModel()
    var key:String = ""
    @State var content:String = ""
    @State var showFlg = true
    
    init(key: String) {
        self.key = key
        getSpeaks()
    }
    
    func getSpeaks() {
        let url:URL = URL(string: "http://127.0.0.1:8000/speeches/")!
        var request = URLRequest(url: url)
        if !key.isEmpty {
            request.setValue("Token \(key)", forHTTPHeaderField: "Authorization")
        }
        let session = URLSession.shared

        let decoder: JSONDecoder = JSONDecoder()
        let this = self
        session.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                let speaks = try decoder.decode([Speak].self, from: data)
//                print("テスト: \(speaks.count)")
                this.getNamedSpeaks(speaks: speaks)
            } catch let e {
                print("JSON Decode Error :\(e)")
            }
        }.resume()
    }
    
    func getNamedSpeaks(speaks: [Speak]) {
        var result:[NamedSpeak] = []
        for speak in speaks {
            var speakerName = SpeakerName(username: "")
            let url:URL = URL(string: "http://127.0.0.1:8000/users/\(speak.speaker)/")!
            let request = URLRequest(url: url)
            let session = URLSession.shared

            let decoder: JSONDecoder = JSONDecoder()
            let this = self
            session.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                do {
                    speakerName = try decoder.decode(SpeakerName.self, from: data)
                    let namedSpeak:NamedSpeak = NamedSpeak(id: speak.id, speakerName: speakerName.username, content: speak.content, created: speak.created)
                    result.append(namedSpeak)
                    this.namedSpeaksModel.addItem(namedSpeak: namedSpeak)
                } catch let e {
                    print("JSON Decode Error :\(e)")
                }
            }.resume()
        }
    }
    
    var body: some View {
        ScrollView {
            if showFlg {
                VStack {
                    Text("掲示板")
                        .frame(width: 300.0)
                    showSpeaks
                    Button(action: {
                        self.namedSpeaksModel.reset()
                        self.getSpeaks()
                    }) {
                        Text("更新")
                    }
                    if !key.isEmpty {
                        HStack {
                            Text("投稿内容: ")
                            TextField("投稿内容", text:     $content)
                        }
                        Button(action: {
                            self.post()
                            self.content = ""
                        }) {
                            Text("投稿")
                        }
                    }
                }
            } else {
                InternetForumView(key: key)
            }
        }
    }
    
    var showSpeaks: some View {
        VStack {
            ForEach(namedSpeaksModel.items, id: \.id) {item in
                VStack(alignment: .leading) {
                    Text("投稿者: \(item.speakerName)")
                    Text(item.created)
                    Text(item.content)
                    Divider()
                }
            }
        }
    }
    
    func post() {
        let url:URL = URL(string: "http://127.0.0.1:8000/speeches/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "speaker=1&content=\(self.content)".data(using: .utf8)
        request.setValue("Token \(key)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: request).resume()
    }
}

struct Speak: Codable {
    let id: Int
    let speaker: Int
    let content: String
    let created: String
}

struct SpeakerName: Codable {
    let username: String
}

struct NamedSpeak {
    let id: Int
    var speakerName: String
    let content: String
    let created: String
}

class NamedSpeaksModel: ObservableObject {

   @Published var items:[NamedSpeak] = []

   func addItem(namedSpeak: NamedSpeak) {
      items.append(namedSpeak)
   }
    
    func reset() {
        items = []
    }
}

struct InternetForumView_Previews: PreviewProvider {
    static var previews: some View {
        InternetForumView(key: "b05eacc1fd4f9def56ca83b88472f413fb76e8b7")
    }
}
