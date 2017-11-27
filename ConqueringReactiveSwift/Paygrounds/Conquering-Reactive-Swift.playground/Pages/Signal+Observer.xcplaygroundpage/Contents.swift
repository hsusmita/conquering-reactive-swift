//: [Previous](@previous)
/*:
## Conquering ReactiveSwift: Signal and Observer
### Part 3
#### This sample code demonstrates how to create and observe a signal. Here, Time elapsed is printed every five seconds, for next 50 seconds.
*/

import UIKit
import ReactiveSwift
import Result
import ReactiveCocoa
import XCPlayground
import PlaygroundSupport

//Create an observer
let signalObserver = Signal<Int, NoError>.Observer (value: { value in
	print("Time elapsed = \(value)")
}, completed: { print("completed") },
   interrupted: { print("interrupted") })

//Create a signal
let (output, input) = Signal<Int, NoError>.pipe()

//Send value to signal
for i in 0..<10 {
	DispatchQueue.main.asyncAfter(deadline: .now() + 5.0 *  Double(i)) {
		input.send(value: i)
 }
}

//Observe the signal
let x = output.observe(signalObserver)

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Conquering ReactiveSwift: SignalProducer](@next)
