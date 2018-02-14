//: [Conquering ReactiveSwift: Primitives](@previous)

/*:
## Conquering ReactiveSwift: Signal
### Part 3

**Goal:** Demonstrates how to create and observe a `Signal`.

**Example:** Time elapsed is printed every 5 seconds, for next 50 seconds.
*/
import UIKit
import ReactiveSwift
import Result
import ReactiveCocoa
import XCPlayground
import PlaygroundSupport

//: ### Create an observer
let signalObserver = Signal<Int, NoError>.Observer (value: { value in
	print("Time elapsed = \(value)")
}, completed: { print("completed") },
   interrupted: { print("interrupted") })

//: ### Create a signal
let (output, input) = Signal<Int, NoError>.pipe()

//: ### Send value to signal
for i in 0..<10 {
	DispatchQueue.main.asyncAfter(deadline: .now() + 5.0 *  Double(i)) {
		input.send(value: i)
 }
}

//: ### Observe the signal
let x = output.observe(signalObserver)

PlaygroundPage.current.needsIndefiniteExecution = true

//: Next - [Conquering ReactiveSwift: SignalProducer](@next)
