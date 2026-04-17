// NotificationsView.swift

import SwiftUI

struct NotificationsView: View {
    @State private var notifications: [String] = []
    @State private var newNotification: String = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(notifications, id: \ .self) { notification in
                        Text(notification)
                    }
                }
                .navigationTitle("Notifications")
                .navigationBarTitleDisplayMode(.inline)

                HStack {
                    TextField("New Notification", text: $newNotification)
                    Button(action: {
                        if !newNotification.isEmpty {
                            addNotification(newNotification)
                            newNotification = ""
                        }
                    }) {
                        Text("Add")
                    }
                }
                .padding()
            }
        }
    }

    private func addNotification(_ notification: String) {
        notifications.append(notification)
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}