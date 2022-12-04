//
//  Buttons.swift
//  Phone
//
//  Created by Oliver Epper on 03.12.22.
//

import SwiftUI
import SwiftUITools
import SwiftSIP

extension ButtonKey {
    public static let one = Self(id: "1")
    public static let two = Self(id: "2")
    public static let three = Self(id: "3")
    public static let four = Self(id: "4")
    public static let five = Self(id: "5")
    public static let six = Self(id: "6")
    public static let seven = Self(id: "7")
    public static let eight = Self(id: "8")
    public static let nine = Self(id: "9")
    public static let zero = Self(id: "0")
    
    public static let numbers: Set = [one, two, three, four, five, six, seven, eight, nine, zero]
    
    public static let a = Self(id: "a")
    public static let b = Self(id: "b")
    public static let c = Self(id: "c")
    public static let d = Self(id: "d")
    
    public static let extraDtmfKeys: Set = [a, b, c, d]
    
    public static let star = Self(id: "*")
    public static let pound = Self(id: "#")
    public static let delete = Self(id: "\u{7F}")
    
    public static let call = Self(id: "call")
    public static let answer = Self(id: "answer")
    public static let hangup = Self(id: "hangup")
    
    public static let enter = Self(id: "enter")
    
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

struct Buttons: View {
    @ObservedObject var model: Model
    
    var body: some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 20) {
            GridRow {
                NumberPadButton(key: ButtonKey.one, onPress: model.send(event:)) { view(title: "1") }
                NumberPadButton(key: ButtonKey.two, onPress: model.send(event:)) { view(title: "2", subtitle: "ABC") }
                NumberPadButton(key: ButtonKey.three, onPress: model.send(event:)) { view(title: "3", subtitle: "DEF") }
            }
            GridRow {
                NumberPadButton(key: ButtonKey.four, onPress: model.send(event:)) { view(title: "4", subtitle: "GHI") }
                NumberPadButton(key: ButtonKey.five, onPress: model.send(event:)) { view(title: "5", subtitle: "JKL") }
                NumberPadButton(key: ButtonKey.six, onPress: model.send(event:)) { view(title: "6", subtitle: "MNO") }
            }
            GridRow {
                NumberPadButton(key: ButtonKey.seven, onPress: model.send(event:)) { view(title: "7", subtitle: "PQRS") }
                NumberPadButton(key: ButtonKey.eight, onPress: model.send(event:)) { view(title: "8", subtitle: "TUV") }
                NumberPadButton(key: ButtonKey.nine, onPress: model.send(event:)) { view(title: "9", subtitle: "WXYZ") }
            }
            GridRow {
                NumberPadButton(key: ButtonKey.star, onPress: model.send(event:)) { view(title: "*") }
                NumberPadButton(key: ButtonKey.zero, onPress: model.send(event:)) { view(title: "0", subtitle: "+") }
                NumberPadButton(key: ButtonKey.pound, onPress: model.send(event:)) { view(title: "#") }
            }
            GridRow() {
                Spacer()
                switch model.inviteSessionState {
                case PJSIP_INV_STATE_CALLING, PJSIP_INV_STATE_EARLY, PJSIP_INV_STATE_CONNECTING, PJSIP_INV_STATE_CONFIRMED:
                    NumberPadButton(key: ButtonKey.hangup, onPress: model.send(event:)) {
                        VStack {
                            Image(systemName: "phone.down.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                    }
                case PJSIP_INV_STATE_INCOMING:
                    HStack {
                        NumberPadButton(key: ButtonKey.hangup, onPress: model.send(event:)) {
                            Image(systemName: "phone.fill.arrow.down.left")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                        Spacer()
                        NumberPadButton(key: ButtonKey.answer, onPress: model.send(event:)) {
                            Image(systemName: "phone.fill.arrow.up.right")
                                .foregroundColor(.green)
                                .font(.title)
                        }
                    }
                default:
                    NumberPadButton(key: ButtonKey.call, onPress: model.send(event:)) {
                        Image(systemName: "phone.down.fill")
                            .foregroundColor(.green)
                            .font(.title)
                    }
                }
                if !model.numberToCall.isEmpty {
                    NumberPadButton(key: ButtonKey.delete, onPress: model.send(event:)) {
                        Image(systemName: "delete.left")
                    }
                } else {
                    NumberPadButton(key: ButtonKey.delete, onPress: model.send(event:)) {
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
