//
//  ContentView.swift
//  InternetForumiOS
//
//  Created by 佐藤智宏 on 2020/04/28.
//  Copyright © 2020 佐藤智宏. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var username:String = ""
    @State var password:String = ""
    @State var password1:String = ""
    @State var password2:String = ""
    @State var loginFlg:Bool = true
    @State var authoricatedFlg:Bool = false
    @State var key:String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("username:")
                    TextField("username", text: $username)
                }
                if loginFlg {
                    HStack {
                        Text("password:")
                        SecureField("password", text:       $password)
                    }
                } else {
                    HStack {
                        Text("password1:")
                        SecureField("password1", text:      $password1)
                    }
                    HStack {
                        Text("password2:")
                        SecureField("password2", text:      $password2)
                    }
                }
                if !authoricatedFlg {
                    Button(action: {
                        if self.loginFlg {
                            self.login()
                        } else {
                            self.register()
                        }
                    }) {
                        if loginFlg {
                            Text("ログイン")
                        } else {
                            Text("新規登録")
                        }
                    }
                    Button(action: {
                        self.loginFlg.toggle()
                        self.username = ""
                        self.password = ""
                    }) {
                        if loginFlg {
                            Text("未登録の方はこちらから")
                        } else {
                            Text("登録済みの方はこちらから")
                        }
                    }
                } else {
                    NavigationLink(destination: InternetForumView(key: key)) {
                        Text("掲示板画面へ")
                    }
                }
            }
        }
    }
    
    func login() {
        let urlString:String = "http://127.0.0.1:8000/rest-auth/login/"
        let httpBody = "username=\(self.username)&password=\(self.password)"
        http(urlString: urlString, httpBody: httpBody)
    }
    
    func register() {
        let urlString:String = "http://127.0.0.1:8000/rest-auth/registration/"
        let httpBody = "username=\(self.username)&password1=\(self.password1)&password2=\(self.password2)"
        http(urlString: urlString, httpBody: httpBody)
    }
    
    func http(urlString: String, httpBody: String) {
        let url:URL = URL(string:  urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody.data(using: .utf8)
        let session = URLSession.shared
        let decoder: JSONDecoder = JSONDecoder()
        let this = self
        session.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                let keyData:KeyData = try decoder.decode(KeyData.self, from: data)
                this.key = keyData.key
                if !this.key.isEmpty {
                    this.authoricatedFlg = true
                }
            } catch let e {
                print("JSON Decode Error :\(e)")
            }
        }.resume()
    }
}

struct KeyData: Codable {
    let key: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
