/**
 *  Copyright (c) 2019 Uber Technologies, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import RxSwift

// Capability of the system to provide Bluetooth LE connectivity.
public enum Capability: String {
    case unsupported, disabled, enabled
}

public protocol BluetoothDetector: class {
    // Observe Bluetooth capability. If Bluetooth LE is unsupported, that will be the only emission.
    var capability: Observable<Capability> { get }

    // Observe Bluetooth enabled/disabled state.
    // If Bluetooth LE is unsupported, a false value will be the only emission.
    var enabled: Observable<Bool> { get }
}
