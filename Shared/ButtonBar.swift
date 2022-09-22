//
//  ButtonBar.swift
//  PJSUA2Demo
//
//  Created by Oliver Epper on 30.08.22.
//

import SwiftUI
import Cpjproject

struct ButtonBar: View {
    @ObservedObject var model: Model

    var body: some View {
        switch model.inviteSessionState {
        case PJSIP_INV_STATE_CALLING, PJSIP_INV_STATE_EARLY, PJSIP_INV_STATE_CONNECTING, PJSIP_INV_STATE_CONFIRMED:
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "phone.down.fill")
                        .foregroundColor(.red)
                        .font(.title)
                    Text("Hangup")
                }.onTapGesture {
                    model.sip.controller.hangupCall()
                }
                Spacer()
            }.padding()
        case PJSIP_INV_STATE_INCOMING:
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "phone.fill.arrow.down.left")
                        .foregroundColor(.red)
                        .font(.title)
                    Text("Reject")
                }.onTapGesture {
                    model.sip.controller.hangupCall()
                }
                Spacer()
                VStack {
                    Image(systemName: "phone.fill.arrow.up.right")
                        .foregroundColor(.green)
                        .font(.title)
                    Text("Accept")
                }.onTapGesture {
                    model.sip.controller.answerCall()
                }
                Spacer()
            }.padding()
        default:
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "phone.down.fill")
                        .foregroundColor(.green)
                        .font(.title)
                    Text("Call")
                }.onTapGesture {
                    try? model.sip.controller.callNumber(model.numberToCall.replacingOccurrences(of: " ", with: ""), onServer: model.server)
                }
                Spacer()
            }.padding()
        }
    }
}

struct ButtonBar_Previews: PreviewProvider {
    static var previews: some View {
        ButtonBar(model: Model())
    }
}
