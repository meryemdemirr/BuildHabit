//
//  AddHabitFlowEnvironment.swift
//  HabitTracker
//

import SwiftUI

private struct DismissEntireAddFlowKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    /// Sheet kökünü kapatır (Kaydet sonrası tam akışı bitirmek için).
    var dismissEntireAddFlow: () -> Void {
        get { self[DismissEntireAddFlowKey.self] }
        set { self[DismissEntireAddFlowKey.self] = newValue }
    }
}
