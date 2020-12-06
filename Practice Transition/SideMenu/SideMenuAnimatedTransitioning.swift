//
//  SideMenuAnimatedTransitioning.swift
//  Practice Transition
//
//  Created by Yi-Cheng Lin on 2020/12/3.
//

import Foundation
import UIKit

class SideMenuAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return SideMenuManager.shared.configurations.presentationDuration
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let manager = SideMenuManager.shared
		// 具體動畫實現
		guard
			let fromVC = transitionContext.viewController(forKey: manager.isPresenting ? .to : .from),
			let nvVC = transitionContext.viewController(forKey: manager.isPresenting ? .from : .to) as? SideMenuNavigationViewController,
			let rootVC = nvVC.viewControllers.first as? SideMenuViewControllerProtocol,
			let fromView = fromVC.view else { return }
		
		
		let containerView = transitionContext.containerView
		containerView.addSubview(nvVC.view)
		
		// TODO: 參數設定
		// 轉場動畫初始化
		rootVC.views.forEach {
			$0.alpha = manager.isPresenting ? 1 : 0
			$0.transform = CGAffineTransform(translationX: manager.isPresenting ? 0 : -60, y: 0)
		}
		nvVC.view.alpha = manager.isPresenting ? 1 : 0
		nvVC.view.frame = CGRect(x: 0, y: 0, width: manager.isPresenting ? manager.configurations.menuWidth : 0, height: fromView.frame.height)
		nvVC.view.layoutIfNeeded()
		
//		Animators
		let presentAnimator = UIViewPropertyAnimator(duration: manager.configurations.presentationDuration, curve: .easeIn, animations: nil)
		let listAnimator = UIViewPropertyAnimator(duration: manager.configurations.presentationDuration, curve: .linear, animations: nil)
		
//		SideMenu main view animation
		presentAnimator.addAnimations {
			nvVC.view.alpha = manager.isPresenting ? 0 : 1
			nvVC.view.frame = CGRect(x: 0, y: 0,
									 width: manager.isPresenting ? 0 : manager.configurations.menuWidth,
									 height: fromView.frame.height)
		}
		
//		SideMenu list items animations
		for (index, view) in rootVC.views.enumerated() {
			listAnimator.addAnimations({
				UIViewPropertyAnimator(duration: manager.configurations.presentationDuration, curve: .linear, animations: {
					view.alpha = manager.isPresenting ? 0 : 1
					view.transform = manager.isPresenting ? CGAffineTransform(translationX: -60, y: 0) : .identity
					nvVC.view.layoutIfNeeded()
				}).startAnimation(afterDelay: Double(index)*0.1)
			})
		}
		
//		Start list items animations with delay
		presentAnimator.addAnimations({
			listAnimator.startAnimation()
		}, delayFactor: 0.5)
		
		
		presentAnimator.addCompletion { _ in transitionContext.completeTransition(true) }
		presentAnimator.startAnimation()
	}
	
	func animationEnded(_ transitionCompleted: Bool) {
//		print("動畫完成")
	}
}
