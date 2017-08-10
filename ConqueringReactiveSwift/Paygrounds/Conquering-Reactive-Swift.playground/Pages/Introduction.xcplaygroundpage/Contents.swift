
//: [Previous](@previous)

/*:

## Sample Code

### This sample code demonstrates reactive and non-reactive way of solving a problem. The following code simply assigns text to a UILabel of a UITextView as you type in.

*/
import UIKit
import Foundation
import ReactiveSwift
import Result
import ReactiveCocoa
import XCPlayground
import PlaygroundSupport

class SimulatorViewController: UIViewController {
	
	let textView = UITextView()
	let label = UILabel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureLabel()
		configureTextView()
	}
	
	func configureTextView() {
		view.addSubview(textView)
		textView.frame = CGRect(x: 20, y: 200, width: 335, height: 100)
		textView.backgroundColor = UIColor.green.withAlphaComponent(0.5)
		textView.becomeFirstResponder()
	}
	
	func configureLabel() {
		view.addSubview(label)
		label.frame = CGRect(x: 20, y: 50, width: 335, height: 100)
		label.backgroundColor = UIColor.cyan.withAlphaComponent(0.5)
		label.numberOfLines = 0
	}
	
	func configureReactively() {
		label.reactive.text <~ textView.reactive.continuousTextValues
	}
	
	func configureNonReactively() {
		textView.delegate = self
		textView.becomeFirstResponder()
	}
}

extension SimulatorViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		label.text = textView.text
	}
}

let viewController = SimulatorViewController()
let currentView = viewController.view!
currentView.frame = CGRect(x: 0, y: 0, width: 375, height: 667)
currentView.backgroundColor = UIColor.white

//viewController.configureReactively()
viewController.configureNonReactively()
PlaygroundPage.current.liveView = currentView
PlaygroundPage.current.needsIndefiniteExecution = true


//: [Next](@next)
