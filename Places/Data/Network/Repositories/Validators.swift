//
//  Validators.swift
//  Places
//
//  Created by Amin Shafiee on 20/06/2026.
//

import Foundation
import Networking

// MARK: - Empty-body validator

struct NonEmptyBodyValidator: ResponseValidator {
    func validate(response: HTTPURLResponse, data: Data) throws {
        if data.isEmpty { throw NetworkError.emptyData }
    }
}
