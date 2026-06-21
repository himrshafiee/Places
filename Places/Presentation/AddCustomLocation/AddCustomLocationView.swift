//
//  AddCustomLocationView.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import SwiftUI

struct AddCustomLocationView: View {

    @State private var viewModel: AddCustomLocationViewModel
    
    init(
        viewModelsContainer: ViewModelsContainer,
        onOpened: @escaping @MainActor () -> Void,
        onWikipediaMissing: @escaping @MainActor () -> Void
    ) {
        _viewModel = State(
            initialValue: viewModelsContainer.makeAddCustomLocationViewModel(
                onOpened: onOpened,
                onWikipediaMissing: onWikipediaMissing
            )
        )
    }

    var body: some View {
        NavigationStack {
            FormContent(viewModel: viewModel)
        }
    }
}

// MARK: - Form body

private struct FormContent: View {

    @Bindable var viewModel: AddCustomLocationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section {
                TextField(String.localized(.addCustomLocationLatTextFieldLabel), text: $viewModel.latitudeText)
                    .keyboardType(.numbersAndPunctuation)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .accessibilityLabel(String.localized(.addCustomLocationLatTextFieldA11yLabel))
                    .accessibilityHint(String.localized(.addCustomLocationLatTextFieldA11yHint))

                TextField(String.localized(.addCustomLocationLonTextFieldLabel), text: $viewModel.longitudeText)
                    .keyboardType(.numbersAndPunctuation)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .accessibilityLabel(String.localized(.addCustomLocationLonTextFieldA11yLabel))
                    .accessibilityHint(String.localized(.addCustomLocationLonTextFieldA11yHint))

                TextField(String.localized(.addCustomLocationNameTextFieldLabel), text: $viewModel.nameText)
                    .accessibilityLabel(String.localized(.addCustomLocationNameTextFieldA11yLabel))
            } header: {
                Text(String.localized(.addCustomLocationFormHeader))
            } footer: {
                if let validation = viewModel.validationMessage {
                    Text(validation)
                        .foregroundStyle(Color(.AddCustomLocation.error))
                        .accessibilityLabel(String(format: .localized(.addCustomLocationFormError), validation))
                } else {
                    Text(String.localized(.addCustomLocationFormFooter))
                }
            }

            Section {
                Button {
                    Task { await viewModel.submit() }
                } label: {
                    Text(String.localized(.openInwikipediaButtonTitle))
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                }
                .tint(Color(.primary))
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSubmit)
                .accessibilityHint(String.localized(.openInwikipediaButtonA11yHint))
            }
        }
        .navigationTitle(String.localized(.addCustomLocationNavigationTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(String.localized(.cancel)) { dismiss() }
            }
        }
    }
}
