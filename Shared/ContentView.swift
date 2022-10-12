//
//  ContentView.swift
//  Shared
//
//  Created by Oliver Epper on 22.09.22.
//

import SwiftUI
import SwiftSIP

struct ContentView: View {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()

    @StateObject private var model = Model()

    var body: some View {

        VStack {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
               let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                HStack(alignment: .top) {
                    Text(verbatim: pj_get_sys_info().pointee.description)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Version: \(version) Build: \(build)")
                        if let date = buildDate {
                            Text(Self.dateFormatter.string(from: date))
                        }
                    }
                }.font(.footnote)
            }
            TextField("Please enter number", text: $model.numberToCall).font(.title)
            DialPad(number: $model.numberToCall)
            ButtonBar(model: model)
            Text(model.inviteSessionState.description)
        }.padding()
    }

    var buildDate: Date? {
        guard let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist"),
        let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
        let infoDate = infoAttr[.modificationDate] as? Date else {
            return nil
        }
        return infoDate
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
