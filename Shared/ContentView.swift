//
//  ContentView.swift
//  Shared
//
//  Created by Oliver Epper on 22.09.22.
//

import SwiftUI
import SwiftSIP

struct ContentView: View {
    @StateObject private var model = Model()

    var body: some View {
        VStack {
            TextField("Please enter number", text: $model.numberToCall).font(.title)
            DialPad(number: $model.numberToCall)
            ButtonBar(model: model)
            Text(model.inviteSessionState.description)
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
