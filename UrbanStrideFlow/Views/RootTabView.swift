import SwiftUI

struct RootTabView: View {
    @StateObject private var viewModel = AppViewModel()

    var body: some View {
        TabView {
            DashboardView(viewModel: viewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            HistoryView(viewModel: viewModel)
                .tabItem {
                    Label("History", systemImage: "calendar")
                }

            BadgesView(viewModel: viewModel)
                .tabItem {
                    Label("Progress", systemImage: "trophy.fill")
                }

            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.teal)
    }
}

#Preview {
    RootTabView()
}
