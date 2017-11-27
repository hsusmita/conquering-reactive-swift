//: [Previous](@previous)
/*:
## Conquering ReactiveSwift: SignalProducer
### Part 4
*/

import UIKit
import ReactiveSwift
import Result
import ReactiveCocoa
import XCPlayground
import PlaygroundSupport

/*:
### startAndObserveSignalProducer
### This sample code demonstrates how to create and start observing a signal producer. Here, the time elapsed is printed every five seconds, for next 50 seconds.
*/
func startAndObserveSignalProducer() {
	//Create a SignalProducer
	let signalProducer: SignalProducer<Int, NoError> = SignalProducer { (observer, lifetime) in
		for i in 0..<10 {
			DispatchQueue.main.asyncAfter(deadline: .now() + 5.0 *  Double(i)) {
				observer.send(value: i)
				if i == 9 {
					observer.sendCompleted()
				}
			}
		}
	}

	//Create an observer
	let signalObserver = Signal<Int, NoError>.Observer (value: { value in
		print("Time elapsed = \(value)")
	}, completed: {
		print("completed")
	}, interrupted: {
		print("interrupted")
	})

	//Start SignalProducer
	signalProducer.start(signalObserver)
}

/*:
### lifetimeAwareSignalProducer
### This sample code demonstrates how to model a signalProducer to be aware of observer being disposed. Here, the time elapsed is printed every five seconds, for next 50 seconds.
*/
func lifetimeAwareSignalProducer() {
	//Create a SignalProducer
	let signalProducer: SignalProducer<Int, NoError> = SignalProducer { (observer, lifetime) in
		for i in 0..<10 {
			DispatchQueue.main.asyncAfter(deadline: .now() + 5.0 *  Double(i)) {
				//If the following the code is omitted, the statement `Execute complex task` is printed even after the observer has been disposed.
				guard !lifetime.hasEnded else {
					observer.sendInterrupted()
					return
				}
				print("Execute complex task")
				observer.send(value: i)
				if i == 9 {
					observer.sendCompleted()
				}
			}
		}
	}

	//Create an observer
	let signalObserver = Signal<Int, NoError>.Observer (value: { value in
		print("Time elapsed = \(value)")
	}, completed: {
		print("completed")
	}, interrupted: {
		print("interrupted")
	})

	//Start SignalProducer
	let disposable = signalProducer.start(signalObserver)

	//Dispose after 10 seconds
	DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
		disposable.dispose()
	}
}

/*:
### valueSignalProducer
### This sample code demonstrates how create a signalProducer with emits just one value and then completes.
*/
func valueSignalProducer() {
	let signalProducer: SignalProducer<Int, NoError> = SignalProducer(value: 1)

	//Create an observer
	let signalObserver = Signal<Int, NoError>.Observer (value: { value in
		print("value received = \(value)")
	}, completed: {
		print("completed")
	}, interrupted: {
		print("interrupted")
	})

	//Start SignalProducer
	signalProducer.start(signalObserver)
}

/*:
### valueSequenceSignalProducer
### This sample code demonstrates how create a signalProducer with emits sequence of values and then completes.
*/
func valueSequenceSignalProducer() {
	let signalProducer: SignalProducer<Int, NoError> = SignalProducer([1, 2, 3, 4, 5])
	//let signalProducer = SignalProducer(values: 1, 2, 3, 4, 5)
	//Create an observer
	let signalObserver = Signal<Int, NoError>.Observer (value: { value in
		print("value received = \(value)")
	}, completed: {
		print("completed")
	}, interrupted: {
		print("interrupted")
	})

	//Start SignalProducer
	signalProducer.start(signalObserver)
}

/*:
### actionSignalProducer
### This sample code demonstrates how create a signalProducer with a closure. This kind of signalProducer calculates the value to be sent from the closure. It completes after sending one value.
*/
func actionSignalProducer() {
	//SignalProducer with an action
	let action: () -> Int = {
		let randomNumber: UInt32 = arc4random_uniform(100)
		return Int(randomNumber)
	}

	let signalProducer: SignalProducer<Int, NoError> = SignalProducer(action)

	//Create an observer
	let signalObserver = Signal<Int, NoError>.Observer (value: { value in
		print("value received = \(value)")
	}, completed: {
		print("completed")
	}, interrupted: {
		print("interrupted")
	})

	//Start SignalProducer
	signalProducer.start(signalObserver)
}

/*:
### signalProducerWithSignal
### This sample code demonstrates how create a signalProducer with a signal.
*/
func signalProducerWithSignal() {
	//Create a signal
	let (output, input) = Signal<Int, NoError>.pipe()

	//Send value to signal
	for i in 0..<10 {
		DispatchQueue.main.asyncAfter(deadline: .now() + 5.0 *  Double(i)) {
			input.send(value: i)
			if i == 9 {
				input.sendCompleted()
			}
		}
	}

	//SignalProducer with an action
	let signalProducer = SignalProducer(output)

	//Create an observer
	let signalObserver = Signal<Int, NoError>.Observer (value: { value in
		print("value received = \(value)")
	}, completed: {
		print("completed")
	}, interrupted: {
		print("interrupted")
	})

	//Start SignalProducer
	signalProducer.start(signalObserver)
}

//startAndObserveSignalProducer()
//lifetimeAwareSignalProducer()
//valueSignalProducer()
//valueSequenceSignalProducer()
//actionSignalProducer()
signalProducerWithSignal()

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Conquering ReactiveSwift: Disposable and Lifetime](@next)

