//: [Conquering ReactiveSwift: SignalProducer](@previous)

/*:
## Conquering ReactiveSwift: Property
### Part 5

**Goal:** Demonstrates how to create and use a `Property`.

**Example:** Time elapsed is printed every N seconds, for next N * 10 seconds.
*/

import UIKit
import Foundation
import ReactiveSwift
import XCPlayground
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

//: ### Define a SignalProducer which emits interger after interval seconds
let signalProducer: SignalProducer<Int, Never> = SignalProducer { (observer, lifetime) in
	let now = DispatchTime.now()
	for index in 0..<10 {
		let timeElapsed = index * 5
		DispatchQueue.main.asyncAfter(deadline: now + Double(timeElapsed)) {
			guard !lifetime.hasEnded else {
				observer.sendInterrupted()
				return
			}
			observer.send(value: timeElapsed)
			if index == 9 {
				observer.sendCompleted()
			}
		}
	}
}
//: ### Define a Property

let property = Property(initial: 0, then: signalProducer)

////: ### Observe values received

property.signal.observeValues { value in
	print("[Observing Signal] Time elapsed = \(value)")
}

//property.producer.startWithValues { value in
//	print("[Observing SignalProducer] Time elapsed = \(value)")
//}

let mutableProperty = MutableProperty(1)

DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
	mutableProperty.value = 3
}
mutableProperty.producer.startWithValues { value in
//	print("value = \(value)")
}

mutableProperty <~ signalProducer

//: Next - [Conquering ReactiveSwift: Action](@next)


