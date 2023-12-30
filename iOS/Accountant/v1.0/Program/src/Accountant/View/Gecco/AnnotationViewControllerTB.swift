//
//  AnnotationViewControllerTB.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/12/30.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Gecco
import UIKit

// 試算表
class AnnotationViewControllerTB: SpotlightViewController {
    
    @IBOutlet var annotationViews: [UIView]!
    
    var stepIndex: Int = 0
    lazy var geccoSpotlight = Spotlight.Oval(center: CGPoint(x: UIScreen.main.bounds.size.width / 2, y: 200 + view.safeAreaInsets.top), diameter: 220)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        spotlightView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupAnnotationViewPosition()
    }
    
    func next(_ labelAnimated: Bool) {
        updateAnnotationView(labelAnimated)
        
        let rightBarButtonFrames = extractRightBarButtonConvertedFrames()
        switch stepIndex {
        case 0:
            spotlightView.appear(
                Spotlight.RoundedRect(
                    center: CGPoint(x: rightBarButtonFrames.midX, y: rightBarButtonFrames.midY),
                    size: CGSize(width: rightBarButtonFrames.width, height: rightBarButtonFrames.height),
                    cornerRadius: 6
                )
            )
        case 1:
            dismiss(animated: true, completion: nil)
        default:
            break
        }
        
        stepIndex += 1
    }
    
    func updateAnnotationView(_ animated: Bool) {
        annotationViews.enumerated().forEach { index, view in
            UIView.animate(withDuration: animated ? 0.25 : 0) {
                view.alpha = index == self.stepIndex ? 1 : 0
            }
        }
    }
}

extension AnnotationViewControllerTB: SpotlightViewDelegate {
    
    func spotlightWillAppear(spotlightView: SpotlightView, spotlight: SpotlightType) {
        print("\(#function): \(spotlight)")
    }
    func spotlightWillMove(spotlightView: SpotlightView, spotlight: (from: SpotlightType, to: SpotlightType), moveType: SpotlightMoveType) {
        print("\(#function): \(spotlight) is gecco spotlight?: \((spotlight.to as? Spotlight.Oval) == geccoSpotlight)")
    }
}

extension AnnotationViewControllerTB: SpotlightViewControllerDelegate {
    
    func spotlightViewControllerWillPresent(_ viewController: SpotlightViewController, animated: Bool) {
        next(false)
    }
    
    func spotlightViewControllerTapped(_ viewController: SpotlightViewController, tappedSpotlight: SpotlightType?) {
        next(true)
    }
    
    func spotlightViewControllerWillDismiss(_ viewController: SpotlightViewController, animated: Bool) {
        print(stepIndex)
        switch stepIndex {
        case 1:
            // スポットライトが最後のUIパーツに当たっている時にダブルタップすると、クラッシュが発生していた対策
            break
        default:
            spotlightView.disappear()
        }
    }
}

private extension AnnotationViewControllerTB {
    
    func setupAnnotationViewPosition() {
        let rightBarButtonFrames = extractRightBarButtonConvertedFrames()
        annotationViews.enumerated().forEach { (offset, annotationView) in
            switch offset {
            case 0:
                annotationView.frame.origin.x = (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)! - annotationView.frame.size.width
                annotationView.frame.origin.y = rightBarButtonFrames.origin.y + 60
            case 1:
                break
            default:
                fatalError("unexpected index \(offset) for \(annotationView)")
            }
        }
    }
    
    var navigationBarHeight: CGFloat { 44 }
    var viewControllerHasNavigationItem: UIViewController? {
        if let controller = presentingViewController as? UINavigationController {
            if controller.viewControllers[0] is FinancialStatementTableViewController {
                let tableViewControllerFinancialStatement = controller.viewControllers[0]
                print(tableViewControllerFinancialStatement)
                if let wSViewController = controller.viewControllers[1] as? TBViewController {
                    print(wSViewController)
                    return controller.viewControllers[1]
                }
            }
            print(controller.viewControllers[0])
            return controller.viewControllers[0]
        }
        return presentingViewController
    }
    
    func extractRightBarButtonConvertedFrames() -> (CGRect) {
        guard
            let firstRightBarButtonItem = viewControllerHasNavigationItem?.navigationItem.rightBarButtonItems?[0].value(forKey: "view") as? UIView
        else {
            fatalError("Unexpected extract view from UIBarButtonItem via value(forKey:)")
        }
        return
            firstRightBarButtonItem.convert(firstRightBarButtonItem.bounds, to: view)
    }
}
