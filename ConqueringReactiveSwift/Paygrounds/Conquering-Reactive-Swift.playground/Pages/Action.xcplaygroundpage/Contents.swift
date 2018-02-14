//: [Conquering ReactiveSwift: SignalProducer](@previous)

/*:
## Conquering ReactiveSwift: Action
### Part 5

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
	func getSignalProducer(interval: Int) -> SignalProducer<Int, NoError> {
		let signalProducer: SignalProducer<Int, NoError> = SignalProducer { (observer, lifetime) in
			for i in 0..<10 {
				DispatchQueue.main.asyncAfter(deadline: .now() + Double(interval *  i)) {
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
		return signalProducer
	}

//: ### Define an action with a closure
	let action = Action<(Int), Int, NoError>(execute: getSignalProducer)

//: ### Observe values received
	action.values.observeValues { value in
		print("Time elapsed = \(value)")
	}

//: ### Observe when action completes
	action.completed.observeValues {
		print("Action completed")
	}

//: ### Apply the action with inputs and start it
	action.apply(1).start()
	action.apply(2).start() //Ignored as action was busy executing

	DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) {
		//Will be executed as it is started after `action.apply(1)` completed
		action.apply(3).start()
	}

//: Next - [Conquering ReactiveSwift: Disposable and Lifetime](@next)

