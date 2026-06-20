//
//  LocationsListRowView.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import SwiftUI

struct LocationsListRowView: View {

    let location: Location
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(location.displayName)
                    .font(.headline)
                Text(location.coordinateDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(location.accessibilityCoordinateDescription)
        .accessibilityHint(String.localized(.locationsListRowViewAccessibilityHint))
        .accessibilityAddTraits(.isButton)
    }
}
