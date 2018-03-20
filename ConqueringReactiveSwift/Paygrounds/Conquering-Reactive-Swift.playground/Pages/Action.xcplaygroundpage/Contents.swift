//: [Conquering ReactiveSwift: Property](@previous)

/*:
## Conquering ReactiveSwift: Action
### Part 6

**Goal:** Demonstrates how to create and apply an `Action`.

**Example:** Time elapsed is printed every N seconds, for next N * 10 seconds.
*/

import UIKit
import Foundation
import ReactiveSwift
import Result
import ReactiveCocoa
import XCPlayground
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

//: ### Returns a SignalProducer which emits interger after interval seconds
	func getSignalProducer(value: Int) -> SignalProducer<Int, NoError> {
		return SignalProducer<Int, NoError> { (observer, lifetime) in
//			print("start")
			for i in 0..<10 {
				DispatchQueue.main.asyncAfter(deadline: .now() + Double(value *  i)) {
					guard !lifetime.hasEnded else {
						observer.sendInterrupted()
						return
					}
					observer.send(value: i)
					if i == 9 {
						observer.sendCompleted()
					}
				}
			}
		}
	}

//: ### Define an action with a closure
	let action = Action<(Int), Int, NoError>(execute: getSignalProducer)

//: ### Observe values received
	action.values.observeValues { value in
		print("Time elapsed = \(value)")
	}

//: ### Observe when action completes
	action.values.observeCompleted {
			print("Action completed")
	}

//: ### Apply the action with inputs and start it
//	action.apply(1).start()
//	action.apply(2).start() //Ignored as action was busy executing
//
//	DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) {
//		//Will be executed as it is started after `action.apply(1)` completed
//		action.apply(3).start()
//	}

//: ### Define an action with condition
     let property1 = Property<Bool>(
		initial: true,
		then: SignalProducer<Bool, NoError>({ (observer, lifetime) in
//			print("Start")
			DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//				print("sent")
				observer.send(value: false)
				observer.sendCompleted()
			}
		})
	)
	let property2 = Property<Int>(
		initial: 1,
		then: SignalProducer<Int, NoError>({ (observer, lifetime) in
//			print("Start")
			let now = DispatchTime.now()
			for i in 0..<10 {
				DispatchQueue.main.asyncAfter(deadline: .now() + Double(i * 2)) {
					//				print("sent")
					observer.send(value: i)
//					observer.sendCompleted()
				}
			}

		})
	)
    let conditionalAction = Action<(Int), Int, NoError>(execute: getSignalProducer)
//	conditionalAction.apply(1).start()

//let conditionalAction = Action<(Int), Int, NoError>(state: property1, enabledIf: { val in
//	return value == true
//
//}, execute: getSignalProducer)
//	conditionalAction.apply(2).start() //Will be executed

//
//	conditionalAction.values.observeValues { value in
//		print("Time elapsed = \(value)")
//	}

let action1 = Action<(Int), Int, NoError>(state: property2) { (value, timeInterval) -> SignalProducer<Int, NoError> in
	print("start")
	return SignalProducer<Int, NoError> { (observer, lifetime) in
		let now = DispatchTime.now()
		for i in 0..<10 {
			DispatchQueue.main.asyncAfter(deadline: now + Double(timeInterval * i)) {
				guard !lifetime.hasEnded else {
					observer.sendInterrupted()
					return
				}
				observer.send(value: value * i)
				if i == 9 {
					observer.sendCompleted()
				}
			}
		}
	}
}

action1.values.observeValues { value in
	print("action1: current value = \(value)")
}

property2.signal.observeValues { value in
	print("property value = \(value)")

}
DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
	action1.apply(1).start()
}
//: Next - [Conquering ReactiveSwift: Disposable and Lifetime](@next)

