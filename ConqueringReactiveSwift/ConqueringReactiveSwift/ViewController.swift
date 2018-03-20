//
//  ViewController.swift
//  ConqueringReactiveSwift
//
//  Created by Susmita Horrow on 10/08/17.
//  Copyright © 2017 hsusmita. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result
import CoreLocation

class ViewController: UIViewController {
	let tableView = UITableView()
	private let manager: CLLocationManager = CLLocationManager()
	let operationQueue = OperationQueue.main

	override func viewDidLoad() {
		super.viewDidLoad()
		let x = Property(value: true)
		let actionDisposable = AnyDisposable { 
			print("is disposed")
		}
		let scopedDisposable = ScopedDisposable(actionDisposable)
		let serialDisposable = SerialDisposable(actionDisposable)
		serialDisposable.inner = AnyDisposable({})
		serialDisposable.dispose()

		let operation1 = BlockOperation {
			print("Operation 1 executing")
		}

		let operation2 = BlockOperation {
			print("Operation 2 executing")
		}

		operation1.addDependency(operation2)

		operationQueue.addOperation(operation1)
		operationQueue.addOperation(operation2)

		let queue = DispatchQueue.global(qos: .background)
		queue.sync(execute: <#T##DispatchWorkItem#>)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

//class LocationServiceManager: NSObject {
//	private let manager: CLLocationManager = CLLocationManager()
//	let permissionGrantedSignal: Signal<Bool, NoError>
//	let locationSignal: Signal<CLLocation, NoError>
//
//	fileprivate let permissionGrantedPipe = Signal<Bool, NoError>.pipe()
//	fileprivate let locationPipe = Signal<CLLocation, NoError>.pipe()
//
//	fileprivate var locationUpdateCompletionBlock: ((CLLocation) -> Void)?
//
//	override init() {
//		permissionGrantedSignal = permissionGrantedPipe.output
//		locationSignal = locationPipe.output
//		super.init()
//		manager.delegate = self
//	}
//
//	func start() {
//		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
//			manager.startUpdatingLocation()
//		} else {
//			manager.requestWhenInUseAuthorization()
//		}
//	}
//}
//
//extension LocationServiceManager: CLLocationManagerDelegate {
//	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//		switch status {
//		case .denied, .notDetermined, .restricted :
//			permissionGrantedPipe.input.send(value: false)
//		case .authorizedWhenInUse, .authorizedAlways:
//			permissionGrantedPipe.input.send(value: true)
//			manager.startUpdatingLocation()
//		}
//	}
//
//	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//		if let currentLocation = locations.first {
//			locationPipe.input.send(value: currentLocation)
//		}
//	}
//}
//
//
//

class LocationServiceManager: NSObject {
	private let manager: CLLocationManager = CLLocationManager()

	//Create a Pipe
	fileprivate let (output, input) = Signal<CLLocation, NoError>.pipe()

	let locationSignal: Signal<CLLocation, NoError>

	override init() {
		locationSignal = output //Assign output of Pipe to public signal
		super.init()
		manager.delegate = self
	}

	func start() {
		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
			manager.startUpdatingLocation()
		} else {
			manager.requestWhenInUseAuthorization()
		}
	}
}

extension LocationServiceManager: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager,
						 didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			manager.startUpdatingLocation()
		}
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let currentLocation = locations.first {
			// Send location through the input end of the signal
			input.send(value: currentLocation)
		}
	}
}


