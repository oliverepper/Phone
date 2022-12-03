//
//  Buttons.swift
//  Phone
//
//  Created by Oliver Epper on 03.12.22.
//

import SwiftUI
import SwiftUITools
import SwiftSIP

struct Buttons: View {
    @ObservedObject var model: Model

    var body: some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 20) {
            GridRow {
                NumberPadButton(key: "1", onPress: model.send(event:)) { view(title: "1") }
                NumberPadButton(key: "2", onPress: model.send(event:)) { view(title: "2", subtitle: "ABC") }
                NumberPadButton(key: "3", onPress: model.send(event:)) { view(title: "3", subtitle: "DEF") }
            }
            GridRow {
                NumberPadButton(key: "4", onPress: model.send(event:)) { view(title: "4", subtitle: "GHI") }
                NumberPadButton(key: "5", onPress: model.send(event:)) { view(title: "5", subtitle: "JKL") }
                NumberPadButton(key: "6", onPress: model.send(event:)) { view(title: "6", subtitle: "MNO") }
            }
            GridRow {
                NumberPadButton(key: "7", onPress: model.send(event:)) { view(title: "7", subtitle: "PQRS") }
                NumberPadButton(key: "8", onPress: model.send(event:)) { view(title: "8", subtitle: "TUV") }
                NumberPadButton(key: "9", onPress: model.send(event:)) { view(title: "9", subtitle: "WXYZ") }
            }
            GridRow {
                NumberPadButton(key: "*", onPress: model.send(event:)) { view(title: "*") }
                NumberPadButton(key: "0", onPress: model.send(event:)) { view(title: "0", subtitle: "+") }
                NumberPadButton(key: "#", onPress: model.send(event:)) { view(title: "#") }
            }
            GridRow() {
                Spacer()
                switch model.inviteSessionState {
                case PJSIP_INV_STATE_CALLING, PJSIP_INV_STATE_EARLY, PJSIP_INV_STATE_CONNECTING, PJSIP_INV_STATE_CONFIRMED:
                    NumberPadButton(key: "hangup", onPress: model.send(event:)) {
                        VStack {
                            Image(systemName: "phone.down.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                    }
                case PJSIP_INV_STATE_INCOMING:
                    HStack {
                        NumberPadButton(key: "hangup", onPress: model.send(event:)) {
                            Image(systemName: "phone.fill.arrow.down.left")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                        Spacer()
                        NumberPadButton(key: "answer", onPress: model.send(event:)) {
                            Image(systemName: "phone.fill.arrow.up.right")
                                .foregroundColor(.green)
                                .font(.title)
                        }
                    }
                default:
                    NumberPadButton(key: "call", onPress: model.send(event:)) {
                        Image(systemName: "phone.down.fill")
                            .foregroundColor(.green)
                            .font(.title)
                    }
                }
                if !model.numberToCall.isEmpty {
                    NumberPadButton(key: "delete", onPress: model.send(event:)) {
                        Image(systemName: "delete.left")
                    }
                } else {
                    NumberPadButton(key: "delete", onPress: model.send(event:)) {
                        Image(systemName: "delete.left")
                    }.hidden()
                }
            }
        }
    }
    
    private func view(title: String, subtitle: String = "") -> some View {
        VStack {
            Text(verbatim: title).font(.headline)
            Text(verbatim: subtitle).font(.subheadline)
        }
    }
}

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        Buttons(model: Model())
    }
}
