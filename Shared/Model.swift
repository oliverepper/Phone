import Foundation
import Combine
import SwiftSIP
import SwiftUI
import SwiftUITools
#if os(iOS)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif


final class Model: ObservableObject {
    @AppStorage("server") var savedServer = ""
    @AppStorage("user") var savedUser = ""

    @Published var connected = false

    private(set) var sip = SwiftSIP()

    @Published var lastCallId = PJSUA_INVALID_ID.rawValue
    @Published var inviteSessionState = PJSIP_INV_STATE_NULL
    @Published var numberToCall = "" {
        didSet {
            if numberToCall ==  "00" { numberToCall = "+" }
        }
    }

    var enterCalls = true

    #if os(macOS)
    @Published var preview: NSView? = nil
    #endif

    private var cancellables = Set<AnyCancellable>()

    init() {}

    func connect() {
        sip.controller.createTransportUsingSRVLookup(withType: PJSIP_TRANSPORT_TLS)
        sip.controller.createAccount(onServer: savedServer, forUser: savedUser) {
            KeychainWrapper.standard.string(forKey: ProcessInfo.processInfo.processName + "_password") ?? ""
        }

        // handle Incoming Calls
        sip.incomingCalls().receive(on: RunLoop.main)
            .print()
            .assign(to: &$lastCallId)

        // handle CallState updates
        sip.callState().receive(on: RunLoop.main).map(\.state)
            .print()
            .assign(to: &$inviteSessionState)

        sip.callState().receive(on: RunLoop.main)
            .print()
            .handleEvents(receiveOutput: { (callId, _) in self.lastCallId = callId })
            .map(\.state)
            .assign(to: &$inviteSessionState)

        sip.controller.libStart()

        #if os(iOS)
        $inviteSessionState.sink { state in
            if state == PJSIP_INV_STATE_EARLY || state == PJSIP_INV_STATE_EARLY || state == PJSIP_INV_STATE_CONNECTING || state == PJSIP_INV_STATE_CONFIRMED {
                UIDevice.current.isProximityMonitoringEnabled = true
            } else {
                UIDevice.current.isProximityMonitoringEnabled = false
            }
        }.store(in: &cancellables)
        #endif

        self.connected = true
    }

    func send(_ event: ProgrammableButton.Event) {
        print("@@@@@ -> \(event)")
        typealias Key = ProgrammableButton.Key
        switch event.key {
        case let key where Key.extraDtmfKeys.contains(key):
            sip.controller.playDTMF(key.id)
        case let key where Key.numbers.contains(key):
            if event.modifier == .longPress {
                if key == .zero { numberToCall = "+" }
                if key == .one { numberToCall = "+4915123595397" }
                if key == .two { numberToCall = "+4989427005.771" }
                sip.controller.playDTMF(key.id)
                break
            }
            if event.modifier == .control {
                if key == .one { sip.controller.playDTMF("1234567890") }
                break
            }
            sip.controller.playDTMF(key.id)
            numberToCall += key.id
        case .delete:
            if event.modifier == .longPress { return numberToCall = "" }
            if numberToCall == "+" { return numberToCall = "0" }
            numberToCall = .init(numberToCall.dropLast(1))
        case .call:
            try? sip.controller.callNumber(sanitizedNumber(number: numberToCall), onServer: savedServer)
            enterCalls = false
        case .answer:
            sip.controller.answerCall(withId: lastCallId)
            enterCalls = false
        case .hangup:
            sip.controller.hangupCall(withId: lastCallId)
            enterCalls = true
        case .enter:
            if enterCalls {
                send(.init(key: .call))
            } else {
                send(.init(key: .hangup))
            }
        default:
            print("@@@@@ Event not handled: \(event)")
        }
    }

    private func sanitizedNumber(number: String) -> String {
        number
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ".", with: "")
    }
}
