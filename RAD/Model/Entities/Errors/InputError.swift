//
//  InputError.swift
//  RAD
//
//  Copyright 2018 NPR
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use
//  this file except in compliance with the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

import Foundation

/// The errors which may ocurr during the process of input data.
///
/// - *requiredDataNotAvailable*: The input data is not available.
/// - *inconsistentData*: The data which was provided is not consistent.
enum InputError: Error {
    case requiredDataNotAvailable, inconsistentData
}
