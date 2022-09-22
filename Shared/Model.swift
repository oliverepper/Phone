import Foundation
import Combine
import SwiftSIP
import Cpjproject
#if os(iOS)
import UIKit
#endif


final class Model: ObservableObject {
    private(set) var sip = SwiftSIP()

    @Published var lastCallId = PJSUA_INVALID_ID.rawValue
    @Published var inviteSessionState = PJSIP_INV_STATE_NULL
    @Published var numberToCall = ""
    @Published var server = "v7oliep.starface-cloud.com"

    private var cancellables = Set<AnyCancellable>()

    init() {
        sip.controller.createTransport(withType: PJSIP_TRANSPORT_TLS, andPort: 5061)
        sip.controller.createAccount(onServer: "v7oliep.starface-cloud.com", forUser: "stdsip") {
            "357wvNilKdwhYWW0ieUVkjv6L82dyB"
        }

        // handle Incoming Calls
        sip.incomingCalls().receive(on: RunLoop.main)
            .print()
            .assign(to: &$lastCallId)

        // handle CalLState updates
        sip.callState().receive(on: RunLoop.main).map(\.state)
            .print()
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
}
