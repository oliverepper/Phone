//
//  Video.swift
//  Phone (iOS)
//
//  Created by Oliver Epper on 17.10.22.
//

import SwiftUI

struct Video: NSViewRepresentable {
    @Binding var view: NSView?

    func makeNSView(context: Context) -> NSView {
        return NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let view {
            nsView.subviews.removeAll()
            nsView.addSubview(view)
        }
    }
}
