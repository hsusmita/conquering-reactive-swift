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

class ViewController: UIViewController {

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
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

