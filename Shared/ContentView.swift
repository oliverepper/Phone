//
//  ContentView.swift
//  Shared
//
//  Created by Oliver Epper on 22.09.22.
//

import SwiftUI
import SwiftSIP
import SwiftUITools

#if os(macOS)
class Preview: ObservableObject {
    @Published var view: NSView?
}

private class _KeyReader: NSView {
    var onPress: (ProgrammableButton.Event) -> Void = { _ in }
    override var acceptsFirstResponder: Bool { true }
    override func keyDown(with event: NSEvent) {
        print("@@@@@ event: \(event)")
        if let key = ProgrammableButton.Key.key(for: event) {
            onPress(.init(key: key))
        }
    }
}

struct KeyReader: NSViewRepresentable {
    let onPress: (ProgrammableButton.Event) -> Void

    func makeNSView(context: Context) -> some NSView {
        let view = _KeyReader()
        view.onPress = onPress
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {}
}
#endif

struct ContentView: View {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()

    @StateObject private var model = Model()
    @State private var text = "Test"

    var body: some View {
        VStack {
            Text(model.numberToCall.isEmpty ? "Please enter number" : model.numberToCall)
                .foregroundColor(model.numberToCall.isEmpty ? .gray : .primary)
                .font(.title)
                .padding()

            Buttons(model: model)
#if os(macOS)
                .background(KeyReader(onPress: model.send(_:)))
#endif
                .padding()





#if os(macOS)
            Video(view: $model.preview)
            Button("Start preview") {
                startPreview()
            }
#endif
            BuildInfo(leftText: pj_get_sys_info().pointee.description + "\nlastCallId: \(model.lastCallId)" + "\ninviteSessionState: \(model.inviteSessionState)")
                .padding(.top)
        }.padding()
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
