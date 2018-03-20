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
var signalObserver = Signal<Int, NoError>.Observer (value: { value in
	print("Time elapsed = \(value)")
}, completed: {
	print("completed")
}, interrupted: {
	print("interrupted")
})

//: ### Create a signal

let signal = Signal<Int, NoError> { observer, lifetime in
	let now = DispatchTime.now()
	for index in (0..<10) {
		let timeElapsed = index * 5
		DispatchQueue.main.asyncAfter(deadline: now + Double(timeElapsed), execute: {
			//1. Send Value to signal
			observer.send(value: timeElapsed)
			if index == 9 {
				//2. Send completed
				observer.sendCompleted()
			}
		})
	}
	//3. Perform clean up if needed
	lifetime.observeEnded {
		print("Do clean up if needed.")
	}
}

let (output, input) = Signal<Int, NoError>.pipe()

let now = DispatchTime.now()
for index in (0..<10) {
	let timeElapsed = index * 5
	DispatchQueue.main.asyncAfter(deadline: now + Double(timeElapsed), execute: {
		//1. Send Value to signal
		input.send(value: timeElapsed)
		if index == 9 {
			//2. Send completed
			input.sendCompleted()
		}
	})
}


//: ### Observe the signal

let disposable = signal.observe(signalObserver)
//let disposable = output.observe(signalObserver)

//: ### Stop observation

DispatchQueue.main.asyncAfter(deadline: .now() + 2 * 5.0) {
	disposable?.dispose()
}
PlaygroundPage.current.needsIndefiniteExecution = true
