//: [Previous](@previous)

import UIKit
import Foundation
import ReactiveSwift
import Result
import ReactiveCocoa
import XCPlayground
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

let signalProducer = SignalProducer<Int, NoError> { (observer, lifetime) in
	for i in 1...10 {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 * Double(i)) {
			observer.send(value: i)
		}
	}
	DispatchQueue.main.asyncAfter(deadline: .now() + 11.0) {
		observer.sendCompleted()
	}
}

//signalProducer.startWithValues { value in
//	print("observing first")
//	print(value)
//}
//
//signalProducer.startWithValues { value in
//	print("observing second")
//	print(value)
//}
func getSignalProducer(value: Int) -> SignalProducer<Int, NoError> {
	return SignalProducer<Int, NoError> { (observer, lifetime) in
		print("input = \(value)")
		for i in 1...10 {
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 * Double(i)) {
				observer.send(value: i * value)
			}
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 11.0) {
			observer.sendCompleted()
		}
	}
}

let action = Action<(Int), Int, NoError>(execute: getSignalProducer)

action.values.observeValues { value in
	print(value)
}
action.apply(2).start()
action.apply(1).start() //Ignored as action was busy executing
action.completed.observeValues {
	print("action completed")
}
DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) {
	action.apply(3).start()
}

//: [Next](@next)
