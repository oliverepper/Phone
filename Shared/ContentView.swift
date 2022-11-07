//
//  ContentView.swift
//  Shared
//
//  Created by Oliver Epper on 22.09.22.
//

import SwiftUI
import SwiftSIP

class Preview: ObservableObject {
    #if os(macOS)
    @Published var view: NSView?
    #endif
}

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
            #if os(macOS)
            Video(view: $model.preview)
            Button("Start preview") {
                startPreview()
            }
            #endif
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

    #if os(macOS)
    private func startPreview() {
        var prm = pjsua_vid_preview_param()
        pjsua_vid_preview_param_default(&prm)
        prm.show = 0
        pjsua_vid_preview_start(0, &prm)
        let windowId = pjsua_vid_preview_get_win(0)
        var windowInfo = pjsua_vid_win_info()
        pjsua_vid_win_get_info(windowId, &windowInfo)
        model.preview = Unmanaged<NSWindow>.fromOpaque(windowInfo.hwnd.info.cocoa.window).takeUnretainedValue().contentView
    }
    #endif
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
