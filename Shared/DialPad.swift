//
//  DialView.swift
//
//  Created by Oliver Epper on 03.02.22.
//

import SwiftUI

enum ButtonState {
    case pressed
    case notPressed
}

struct PressedModifier: ViewModifier {
    @GestureState private var isPressed = false
    let changeState: (ButtonState) -> Void

    init(changeState: @escaping (ButtonState) -> Void) {
        self.changeState = changeState
    }

    func body(content: Content) -> some View {
        let drag = DragGesture(minimumDistance: 0)
            .updating($isPressed) { value, gestureState, transition in
                gestureState = true
            }

        return content
            .gesture(drag)
            .onChange(of: isPressed) { pressed in
                if pressed {
                    self.changeState(.pressed)
                } else {
                    self.changeState(.notPressed)
                }
            }
    }
}
struct DialPadButton<T>: View where T: View {
    @State private var pressed = false
    var key: String
    var caption: T?
    var border = true
    var action: ((String, Bool) -> Void)? = { _, _ in }

    var body: some View {
        ZStack {
            if border {
                RoundedRectangle(cornerRadius: 12).stroke(Color.accentColor)
            }
            if caption == nil {
                VStack {
                    Text(key)
                }
            } else {
                caption
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .modifier(PressedModifier(changeState: { (state) in
            if state == .pressed {
                pressed = true
            } else {
                withAnimation(.easeOut(duration: 0.1)) {
                    pressed = false
                }
            }
        }))
        .simultaneousGesture(LongPressGesture().onEnded { _ in
            action?(key, true)
        })
        .simultaneousGesture(TapGesture().onEnded { _ in
            action?(key, false)
        })
        .scaleEffect(pressed ? 0.9 : 1)
    }
}

extension DialPadButton where T == VStack<Text> {
    init(key: String, action: @escaping (String, Bool) -> Void) {
        self.key = key
        self.action = action
        self.caption = VStack {
            Text(key)
        }
    }

}

struct DialPad: View {
    @Binding var number: String

    var body: some View {
        VStack {
            row(keys: "1","2","3")
            row(keys: "4","5","6")
            row(keys: "7","8","9")
            row(keys: "-","0","⌫")
        }
    }

    private func row(keys: String...) -> some View {
        HStack {
            ForEach(keys, id:\.self) { key in
                if key == "0" {
                    DialPadButton(key: key, caption: VStack {
                        Text(key)
                        Text("+").font(.subheadline)
                    }, action: press(key:longPress:))
                } else {
                    DialPadButton(key: key, action: press(key:longPress:))
                }
            }
        }
    }

    private func press(key: String, longPress: Bool) {
        switch (key, longPress) {
        case ("⌫", false):
            if number.count > 0 {
                number.removeLast()
            }
        case ("⌫", true):
            number = ""
        case ("0", false):
            if number == "0" {
                number = "+"
            } else {
                number += "0"
            }
        case ("0", true):
            number += "+"
        default:
            number += key
        }
    }
}
