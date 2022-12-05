//
//  LoginView.swift
//  Phone
//
//  Created by Oliver Epper on 05.12.22.
//

import SwiftUI

struct LoginView: View {
    @State var model: Model
    @State private var password = ""

    var body: some View {
        VStack {
            TextField("Server", text: $model.savedServer)
            TextField("Username", text: $model.savedUser)
            SecureField("Password", text: $password)

            Button("Login") {
                let savedPassword = KeychainWrapper.standard.string(forKey: ProcessInfo.processInfo.processName + "_password")
                if savedPassword != password && !password.isEmpty{
                    KeychainWrapper.standard.set(password, forKey: ProcessInfo.processInfo.processName + "_password")
                }
                model.connect()
            }
        }.padding()
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(model: Model())
    }
}
