//
//  LocationsListView.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import SwiftUI

struct LocationsListView: View {

    @State private var viewModel: LocationsListViewModel
    
    // MARK: Private properties
    
    private let router: LocationsRouter
    private let viewModelsContainer: ViewModelsContainer

    init(router: LocationsRouter, viewModelsContainer: ViewModelsContainer) {
        self.router = router
        self.viewModelsContainer = viewModelsContainer
        _viewModel = State(initialValue: viewModelsContainer.makeLocationsListViewModel())
    }

    var body: some View {
        LocationsListContent(
            viewModel: viewModel,
            router: router,
            viewModelsContainer: viewModelsContainer
        )
    }
}

// MARK: - Body

private struct LocationsListContent: View {

    @Bindable var viewModel: LocationsListViewModel
    @Bindable var router: LocationsRouter
    
    let viewModelsContainer: ViewModelsContainer

    var body: some View {
        NavigationStack(path: $router.path) {
            content
                .navigationTitle(String.localized(.locationsListNavigationTitle))
                .refreshable { await viewModel.load() }
                .task { await viewModel.load() }
                .alert(
                    String.localized(.locationsListWikipediaErrorTitle),
                    isPresented: $viewModel.wikipediaMissingAlertVisible
                ) {
                    Button(String.localized(.ok), role: .cancel) { }
                } message: {
                    Text(String.localized(.locationsListWikipediaErrorMessage))
                }
                .alert(
                    String.localized(.generalErrorTitle),
                    isPresented: $viewModel.errorAlertVisible
                ) {
                    Button(String.localized(.ok), role: .cancel) { }
                } message: {
                    Text(viewModel.errorAlertMessage ?? String.localized(.generalErrorMessage))
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            VStack(spacing: 12) {
                ProgressView()
                Text(String.localized(.locationsListLoadingText))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(String.localized(.locationsListLoadingTextAccessibilityLabel))

        case .loaded(let locations) where locations.isEmpty:
            ContentUnavailableView {
                Label(String.localized(.locationsListEmptyTitle), systemImage: "mappin.slash")
            } description: {
                Text(String.localized(.locationsListEmptyDescription))
            } actions: {
                Button(String.localized(.tryAgain)) {
                    Task { await viewModel.load() }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(String.localized(.tryAgain))
                .accessibilityAddTraits(.isButton)
            }
            
        case .loaded(let locations):
            List(locations, id: \.self) { location in
                LocationsListRowView(location: location) {
                    Task { await viewModel.select(location) }
                }
            }
            .listStyle(.plain)

        case .failed(let message):
            ContentUnavailableView {
                Label(String.localized(.locationsListError), systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button(String.localized(.tryAgain)) {
                    Task { await viewModel.load() }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(String.localized(.tryAgain))
                .accessibilityAddTraits(.isButton)
            }
        }
    }
}
