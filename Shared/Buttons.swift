//
//  Buttons.swift
//  Phone
//
//  Created by Oliver Epper on 03.12.22.
//

import SwiftUI
import SwiftUITools
import SwiftSIP

extension ProgrammableButton.Key {
    public static let one       = Self(id: "1")
    public static let two       = Self(id: "2")
    public static let three     = Self(id: "3")
    public static let four      = Self(id: "4")
    public static let five      = Self(id: "5")
    public static let six       = Self(id: "6")
    public static let seven     = Self(id: "7")
    public static let eight     = Self(id: "8")
    public static let nine      = Self(id: "9")
    public static let zero      = Self(id: "0")
    

    
    public static let a         = Self(id: "a")
    public static let b         = Self(id: "b")
    public static let c         = Self(id: "c")
    public static let d         = Self(id: "d")

    public static let star      = Self(id: "*")
    public static let pound     = Self(id: "#")
    public static let delete    = Self(id: "\u{7F}")
    
    public static let call      = Self(id: "call")
    public static let answer    = Self(id: "answer")
    public static let hangup    = Self(id: "hangup")

    public static let enter     = Self(id: "enter")
    
    public static let numbers: Set = [one, two, three, four, five, six, seven, eight, nine, zero]
    public static let extraDtmfKeys: Set = [a, b, c, d]
    public static var all: Set = numbers
        .union(extraDtmfKeys)
        .union([star, pound, delete])
        .union([call, answer, hangup])
        .union([enter])
    
#if os(macOS)
    public static func key(for event: NSEvent) -> Self? {
        if event.keyCode == 36 { return .enter }
        return all.filter { $0.id == event.characters }.first
    }
#endif
}

typealias Btn = ProgrammableButton.Button

struct Buttons: View {
    @ObservedObject var model: Model
    
    var body: some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 20) {
            GridRow {
                Btn(key: .one,      onPress: model.send(_:)) { view(title: "1") }
                Btn(key: .two,      onPress: model.send(_:)) { view(title: "2", subtitle: "ABC") }
                Btn(key: .three,    onPress: model.send(_:)) { view(title: "3", subtitle: "DEF") }
            }
            GridRow {
                Btn(key: .four,     onPress: model.send(_:)) { view(title: "4", subtitle: "GHI") }
                Btn(key: .five,     onPress: model.send(_:)) { view(title: "5", subtitle: "JKL") }
                Btn(key: .six,      onPress: model.send(_:)) { view(title: "6", subtitle: "MNO") }
            }
            GridRow {
                Btn(key: .seven,    onPress: model.send(_:)) { view(title: "7", subtitle: "PQRS") }
                Btn(key: .eight,    onPress: model.send(_:)) { view(title: "8", subtitle: "TUV") }
                Btn(key: .nine,     onPress: model.send(_:)) { view(title: "9", subtitle: "WXYZ") }
            }
            GridRow {
                Btn(key: .star,     onPress: model.send(_:)) { view(title: "*") }
                Btn(key: .zero,     onPress: model.send(_:)) { view(title: "0", subtitle: "+") }
                Btn(key: .pound,    onPress: model.send(_:)) { view(title: "#") }
            }
            GridRow() {
                Spacer()
                switch model.inviteSessionState {
                case PJSIP_INV_STATE_CALLING, PJSIP_INV_STATE_EARLY, PJSIP_INV_STATE_CONNECTING, PJSIP_INV_STATE_CONFIRMED:
                    Btn(key: .hangup, onPress: model.send(_:)) {
                        VStack {
                            Image(systemName: "phone.down.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                    }
                case PJSIP_INV_STATE_INCOMING:
                    HStack {
                        Btn(key: .hangup, onPress: model.send(_:)) {
                            Image(systemName: "phone.fill.arrow.down.left")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                        Spacer()
                        Btn(key: .answer, onPress: model.send(_:)) {
                            Image(systemName: "phone.fill.arrow.up.right")
                                .foregroundColor(.green)
                                .font(.title)
                        }
                    }
                default:
                    Btn(key: .call, onPress: model.send(_:)) {
                        Image(systemName: "phone.down.fill")
                            .foregroundColor(.green)
                            .font(.title)
                    }
                }
                if !model.numberToCall.isEmpty {
                    Btn(key: .delete, onPress: model.send(_:)) {
                        Image(systemName: "delete.left")
                    }
                } else {
                    Btn(key: .delete, onPress: model.send(_:)) {
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
