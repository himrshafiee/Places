//
//  AddCustomLocationViewModelTests.swift
//  Places
//
//  Created by Amin Shafiee on 21/06/2026.
//

import Foundation
import Testing
@testable import Places

@MainActor
@Suite("AddCustomLocationViewModel")
struct AddCustomLocationViewModelTests {
    
    final class CallbackRecorder: @unchecked Sendable {
        private(set) var onOpenedCount = 0
        private(set) var onMissingCount = 0

        @MainActor func recordOpened() { onOpenedCount += 1 }
        @MainActor func recordMissing() { onMissingCount += 1 }
    }

    private func makeSUT(
        openResult: Result<Bool, Error> = .success(true)
    ) -> (AddCustomLocationViewModel, MockOpenLocationInWikipediaUseCase, CallbackRecorder) {
        let open = MockOpenLocationInWikipediaUseCase()
        open.stubbedResult = openResult
        let recorder = CallbackRecorder()
        let sut = AddCustomLocationViewModel(
            openLocationUseCase: open,
            onOpened: { recorder.recordOpened() },
            onWikipediaMissing: { recorder.recordMissing() }
        )
        return (sut, open, recorder)
    }
    
    // MARK: - Initial state

    @Test("Starts with empty inputs, no validation message, and cannot submit")
    func initialState() {
        let (sut, _, _) = makeSUT()
        #expect(sut.latitudeText == "")
        #expect(sut.longitudeText == "")
        #expect(sut.nameText == "")
        #expect(sut.validationMessage == nil)
        #expect(sut.canSubmit == false)
    }

    // MARK: - canSubmit / validationMessage

    @Test("canSubmit becomes true when both coordinates are valid")
    func canSubmitTrueWhenCoordinatesValid() {
        let (sut, _, _) = makeSUT()
        sut.latitudeText = "52.36"
        sut.longitudeText = "4.9"
        #expect(sut.canSubmit == true)
        #expect(sut.validationMessage == nil)
    }
    
    @Test("Validation message is set when both fields are filled but out of range")
    func validationMessageSetWhenOutOfRange() {
        let (sut, _, _) = makeSUT()
        sut.latitudeText = "95"
        sut.longitudeText = "0"
        #expect(sut.validationMessage == String.localized(.coordinateIsNotValid))
        #expect(sut.canSubmit == false)
    }
}
