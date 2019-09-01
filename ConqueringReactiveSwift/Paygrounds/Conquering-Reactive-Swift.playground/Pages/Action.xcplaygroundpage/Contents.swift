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
import XCPlayground
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

func generateSignalProducer() {
	let signalProducerGenerator: (Int) -> SignalProducer<Int, Never>  = { timeInterval in
		return SignalProducer<Int, Never> { (observer, lifetime) in
			let now = DispatchTime.now()
			for index in 0..<10 {
				let timeElapsed = index * timeInterval
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
	}

	let signalProducer1 = signalProducerGenerator(1)
	let signalProducer2 = signalProducerGenerator(2)

	signalProducer1.startWithValues { value in
		print("value from signalProducer1 = \(value)")
	}

	signalProducer2.startWithValues { value in
		print("value from signalProducer2 = \(value)")
	}
}

func basicAction() {
	//: ### Returns a SignalProducer which emits interger after interval seconds
	let signalProducerGenerator: (Int) -> SignalProducer<Int, Never>  = { timeInterval in
		return SignalProducer<Int, Never> { (observer, lifetime) in
			let now = DispatchTime.now()
			for index in 0..<10 {
				let timeElapsed = index * timeInterval
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
	}

	//: ### Define an action with a closure
	let action = Action<(Int), Int, Never>(execute: signalProducerGenerator)

	//: ### Observe values received
	action.values.observeValues { value in
		print("Time elapsed = \(value)")
	}

	//: ### Observe when action completes
	action.values.observeCompleted {
		print("Action completed")
	}

	//: ### Apply the action with inputs and start it
	action.apply(1).start()
	action.apply(2).start() //Ignored as action was busy executing
	DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) {
		//Will be executed as it is started after `action.apply(1)` completed
		action.apply(3).start()
	}
}

func textSignalGenerator(text: String) -> Signal<String, Never> {
    return Signal<String, Never> { (observer, _) in
        let now = DispatchTime.now()
        for index in 0..<text.count {
            DispatchQueue.main.asyncAfter(deadline: now + 1.0 * Double(index)) {
                let indexStartOfText = text.index(text.startIndex, offsetBy: 0)
                let indexEndOfText = text.index(text.startIndex, offsetBy: index)
                let substring = text[indexStartOfText...indexEndOfText]
                let value = String(substring)
                observer.send(value: value)
            }
        }
    }
}

func lengthCheckerSignalProducer(text: String, minimumLength: Int) ->  SignalProducer<Bool, Never> {
    return SignalProducer<Bool, Never> { (observer, _) in
        observer.send(value: (text.count > minimumLength))
        observer.sendCompleted()
    }
}

func actionWithState() {
	let title = "ReactiveSwift"    
	let titleSignal = textSignalGenerator(text: title)
	let titleProperty = Property(initial: "", then: titleSignal)
    
    let titleLengthChecker = Action<Int, Bool, Never>(
        state: titleProperty, 
        execute: lengthCheckerSignalProducer)

	titleLengthChecker.values.observeValues { isValid in
		print("is title valid = \(isValid)")
	}

	for i in 0..<title.count {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(i)) {
			titleLengthChecker.apply(10).start()
		}
	}
}

func conditionallyEnabledAction() {
    let title = "ReactiveSwift"    
    let titleSignal = textSignalGenerator(text: title)
    let titleProperty = Property(initial: "", then: titleSignal)
    
    let titleLengthChecker = Action<Int, Bool, Never>(
        state: titleProperty, 
        enabledIf: { $0.count > 5 },
        execute: lengthCheckerSignalProducer
    )
    
    titleLengthChecker.values.observeValues { isValid in
        print("is title valid = \(isValid)")
    }
    
    for i in 0..<title.count {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(i)) {
            titleLengthChecker.apply(10).start()
        }
    }
}
/*//: ### Returns a SignalProducer which emits interger after interval seconds
	func getSignalProducer(value: Int) -> SignalProducer<Int, Never> {
		return SignalProducer<Int, Never> { (observer, lifetime) in
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
	let action = Action<(Int), Int, Never>(execute: getSignalProducer)

//: ### Observe values received
	action.values.observeValues { value in
		print("Time elapsed = \(value)")
	}

//: ### Observe when action completes
	action.values.observeCompleted {
			print("Action completed")
	}

//: ### Apply the action with inputs and start it
	action.apply(1).start()
	action.apply(2).start() //Ignored as action was busy executing
	DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) {
		//Will be executed as it is started after `action.apply(1)` completed
		action.apply(3).start()
	}
*/

//generateSignalProducer()
//basicAction()
//actionWithState()
conditionallyEnabledAction()
//: Next - [Conquering ReactiveSwift: Disposable and Lifetime](@next)

