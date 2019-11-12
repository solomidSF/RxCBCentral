# RxCBCentral
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

## Overview

Since iOS 5 and Android 4.3 first introduced Bluetooth LE compatibility, the same challenges persist when integrating with peripherals: dealing with the implicit serial nature of BLE GATT, implementing retry logic to handle connection and GATT errors, using outdated development patterns (delegate pattern in 2019?)...the list goes on.

For those tired of writing eerily similar, yet subtly different code for every Bluetooth LE peripheral, RxCBCentral provides a standardized, simple paradigm for connecting to and communicating with peripherals from the central role in a completely reactive manner, leveraging RxSwift around Apple's CoreBluetooth.

Similar to the RxSwift and RxJava, RxCBCentral and [Android's RxCentralBle](https://github.com/uber/RxCentralBle/) allow mobile engineers who work on different platforms to use similar protocols and speak the same language to accomplish a similar goal, enabling increased developer efficiency and simplifying the process of creaing BLE implementations with platform parity.

Check out our detailed [Wiki](https://github.com/uber/RxCBCentral/wiki) for designs and examples for all the capabilities of RxCBCentral.


## Usage

RxCBCentral makes Bluetooth connection and communication simple.

Scan, Connect and Disconnect:
```swift
let peripheralManager = RxPeripheralManager()
let connectionManager = ConnectionManager(rxPeripheralManager: peripheralManager, queue: nil, options: nil)

// connects to the first device found with matching services and characteristics
let connectionDisposable = 
    connectionManager
    .connectToPeripheral(with: [serviceUUID, characteristicUUID], scanMatcher: nil)
    .subscribe(onNext: { (peripheral: RxPeripheral) -> in
        // IMPORTANT: inject the RxPeripheral into the manager after connecting
        self.peripheralManager.rxPeripheral = peripheral
    })
    
// disconnect
connectionDisposable.dispose()
```

Scan, Connect, and Read:
```swift
let scanMatcher = RssiScanMatcher()
let peripheralManager = RxPeripheralManager()
let connectionManager = ConnectionManager(rxPeripheralManager: peripheralManager, queue: nil, options: nil)

connectionManager
    .connectToPeripheral(with: [serviceUUID, characteristicUUID], scanMatcher: scanMatcher)  // connect to closest peripheral using RSSI
    .flatMapLatest { (peripheral: RxPeripheral) -> Data in
        // IMPORTANT: inject the RxPeripheral into the manager after connecting
        self.peripheralManager.rxPeripheral = peripheral
        
        return self.peripheralManager.queue(operation: Read(service: serviceUUID, characteristic: characteristicUUID))
    }
    .subscribe(onNext: { (data: Data?) in
        // do something with read BLE data
    })
    .disposed(by: disposeBag)
```

Scan, Connect, and Write:
```swift
guard let data = Data(base64Encoded: "A3V1") else { return }

connectionManager
    .connectToPeripheral(with: [serviceUUID, characteristicUUID], scanMatcher: nil)
    .flatMapLatest { (peripheral: RxPeripheral) -> Completable in
        // IMPORTANT: inject the RxPeripheral into the manager after connecting
        self.peripheralManager.rxPeripheral = peripheral
        
        return self.peripheralManager.queue(operation: Write(service: serviceUUID, characteristic: characteristicUUID, data: data))
    }
    .subscribe(onCompleted: {
        // do something on write completion
    })
    .disposed(by: disposeBag)
```

After connecting, you can use the `RxPeripheralManager` to queue read and write BLE operatons, as well as setting up subscriptions to notifications for a particular characteristic.

Subscribe for Notify Events:
```swift
let peripheralManager = RxPeripheralManager()

peripheralManager
    .isConnected
    .filter { $0 } // wait until we're connected before performing BLE operations
    .flatMapLatest { _ -> Observable<Data> in
        // listen for Heart Rate Measurement events
        return self.peripheralManager.receiveNotifications(for: CBUUID(string: "2A37"))
    }
    .subscribe(onNext: { data in
        // do something with Heart Rate Measurement data
    })
    .disposed(by: disposeBag)
```

## Integration steps

## [Carthage](https://github.com/Carthage/Carthage)

Carthage a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.
To integrate RxCBCentral into your Xcode project using Carthage, specify it in your `Cartfile`:
```swift
github "uber/RxCBCentral ~> 1.0"
```
```bash
$ carthage update
```

## [Swift Package Manager](https://github.com/apple/swift-package-manager)
Create a `Package.swift` file. If one already exists, add a new RxCBCentral `package` to your dependencies.

```swift
// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "RxCBCentralProject",
  dependencies: [
    .package(url: "https://github.com/uber/RxCBCentral", from: "1.0.0")
  ],
  targets: [
    .target(name: "RxCBCentralProject", dependencies: ["RxCBCentral"])
  ]
)
```

```bash
$ swift build
```

## Sample App

See the [ExampleApp](https://github.com/uber/RxCBCentral/tree/master/ExampleApp) in this repo for example usages of the library, and visualize low level BLE operations happening in realtime (scanning, discovery events, connecting, etc.).
