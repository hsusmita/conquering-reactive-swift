//: [Previous](@previous)

import UIKit
import ReactiveSwift
import ReactiveCocoa
import XCPlayground
import PlaygroundSupport


/*:
### lifetimeAwareSignalProducer
### This sample code demonstrates how to model a signalProducer to be aware of observer being disposed. Here, the time elapsed is printed every five seconds, for next 50 seconds.
*/
func timerSignalProducer() -> SignalProducer<Int, Never> {
	return SignalProducer { (observer, lifetime) in
		for i in 0..<10 {
			DispatchQueue.main.asyncAfter(deadline: .now() + 5.0 *  Double(i)) {
				//If the following the code is omitted, the statement `Execute complex task` is printed even after the observer has been disposed.
				guard !lifetime.hasEnded else {
					print("The Signal is interrupted")
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
}

class ScopedDisposableExample {
	let signalProducer = timerSignalProducer()
	var scopedDisposable: ScopedDisposable<AnyDisposable>?

	func startTimer() {
		let disposable = signalProducer.startWithValues { values in
			print("values = \(values)")
		}
		scopedDisposable = ScopedDisposable(disposable)
	}

	deinit {
		print("deinit called")
	}
}

class CompositeDisposableExample {
	let oddSignalProducer = SignalProducer<Int, Never>([1, 3, 5, 7, 9])
	let evenSignalProducer = SignalProducer<Int, Never>([0, 2, 4, 6, 8])

	var compositeDisposable = CompositeDisposable()

	init() {
		compositeDisposable += oddSignalProducer.startWithValues { values in
			print("values = \(values)")
		}
		compositeDisposable += evenSignalProducer.startWithValues { values in
			print("values = \(values)")
		}

		compositeDisposable.add {
			print("Disposed")
		}
	}

	deinit {
		compositeDisposable.dispose()
		print("deinit called")
	}
}

class SerialDisposableExample {
	let signalProducer = timerSignalProducer()
	var serialDisposable = SerialDisposable()

	func startTimer() {
		self.serialDisposable.inner = self.signalProducer
//			.take(during: self.reactive.lifetime)
			.on(starting: {
				print("loading start")
			}).on(value: { [unowned self] items in
				print("value = \(items)")
//				self.items.append(contentsOf: items)
//				self.tableView.reloadData()
			}).on(failed: { error in
				print("error")
			}).on(event: { [weak self] event in
//				guard self != nil else { return }
//				if !event.isCompleted {
//					print("loading finished")
//					self?.stopAnimating()
//				}
			}).start()
	}

	deinit {
		serialDisposable.dispose()
		print("deinit called")
	}

}
class ExampleClass {
	var scopedDisposableExample: ScopedDisposableExample? = ScopedDisposableExample()
	var compositeDisposableExample: CompositeDisposableExample? = CompositeDisposableExample()
	var serialDisposableExample: SerialDisposableExample? = SerialDisposableExample()

	init() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
//			self?.scopedDisposableExample = nil
			self?.compositeDisposableExample = nil
			print(self?.compositeDisposableExample?.compositeDisposable.isDisposed)
//			self?.serialDisposableExample = nil
		}
	}
}

//var disposable = CompositeDisposableExample()

var example = ExampleClass()

//example.scopedDisposableExample?.startTimer()
//example.compositeDisposableExample
//example.serialDisposableExample?.startTimer()
//DispatchQueue.main.asyncAfter(deadline: .now() + 5.0 *  Double(3)) {
//	example.serialDisposableExample?.startTimer()
//}

PlaygroundPage.current.needsIndefiniteExecution = true

/*
class Leaker {
	let mutableProperty = MutableProperty<Int>(0)

	var wrapperProperty: Property<Int> {
		return Property(self.mutableProperty)
	}

	private var disposable: ScopedDisposable<AnyDisposable>?

	init() {
		let disposable = CompositeDisposable()

		disposable += self.wrapperProperty.producer
			.startWithValues { value in
				print("\(value)")
		}
		self.disposable = ScopedDisposable(disposable)
	}
}

class OtherClass {
	let leaker: Leaker?

	init() {
		self.leaker = Leaker()
	}
}

var otherClass: OtherClass? = OtherClass()*/
//: [Next](@next)

class Processor: NSObject {
}

extension Reactive where Base: Processor {
    var target: BindingTarget<Int> {
        return self.makeBindingTarget { (base, value) in
        }
    }
}

let signalObserver = Signal<Int, Never>.Observer (
    value: { value in
        print("Time elapsed = \(value)")
},
    completed: { print("completed") },
    interrupted: { print("interrupted") }
)
