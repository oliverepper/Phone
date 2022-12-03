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
    private(set) var sip = SwiftSIP()

    @Published var lastCallId = PJSUA_INVALID_ID.rawValue
    @Published var inviteSessionState = PJSIP_INV_STATE_NULL
    @Published var numberToCall = ""
    @Published var server = "v7oliep.starface-cloud.com"

    #if os(macOS)
    @Published var preview: NSView? = nil
    #endif

    private var cancellables = Set<AnyCancellable>()

    init() {
        sip.controller.createTransport(withType: PJSIP_TRANSPORT_TLS, andPort: 5061)
        sip.controller.createAccount(onServer: server, forUser: "stdsip") {
            ProcessInfo.processInfo.environment["SIP_PASSWORD"] ?? ""
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
    }

    func send(event: ButtonEvent) {
        print(event.key)
        switch event.key {
        case let k where (0...9).map(String.init).contains(k):
            if k == "0" && event.modifier == .isLongPress && numberToCall.isEmpty {
                sip.controller.playDTMF(event.key)
                numberToCall = "+"
                break
            }
            if k == "1" && event.modifier == .isLongPress {
                sip.controller.playDTMF(event.key)
                numberToCall = "+4915123595397"
                break
            }
            if k == "1" && event.modifier == .control {
                sip.controller.playDTMF("1234567890")
                return
            }
            if k == "2" && event.modifier == .isLongPress {
                sip.controller.playDTMF(event.key)
                numberToCall = "+4989427005.771"
                break
            }
            numberToCall += event.key
            sip.controller.playDTMF(event.key)
        case "delete":
            if event.modifier == .isLongPress { numberToCall = ""}
            numberToCall = .init(numberToCall.dropLast(1))
        case "call":
            try? sip.controller.callNumber(numberToCall.replacingOccurrences(of: " ", with: ""), onServer: server)
        case "answer":
            sip.controller.answerCall(withId: lastCallId)
        case "hangup":
            sip.controller.hangupCall(withId: lastCallId)
        default:
            numberToCall += event.key
        }
    }
}
