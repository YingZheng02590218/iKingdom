//
//  AnnotationViewControllerSettingsCategory.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/11/20.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Gecco
import UIKit

class AnnotationViewControllerSettingsCategory: SpotlightViewController {

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
        default:
            if let navigationController = presentingViewController as? UINavigationController,
            let navigationController2 = navigationController.viewControllers.last as? UINavigationController,
            let presentingViewController = navigationController2.viewControllers.first as? SettingsCategoryTableViewController {
                dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                    // チュートリアル対応 コーチマーク型
                    presentingViewController.finishAnnotation()
                })
            }
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

extension AnnotationViewControllerSettingsCategory: SpotlightViewDelegate {
    
    func spotlightWillAppear(spotlightView: SpotlightView, spotlight: SpotlightType) {
        print("\(#function): \(spotlight)")
    }
    func spotlightWillMove(spotlightView: SpotlightView, spotlight: (from: SpotlightType, to: SpotlightType), moveType: SpotlightMoveType) {
        print("\(#function): \(spotlight) is gecco spotlight?: \((spotlight.to as? Spotlight.Oval) == geccoSpotlight)")
    }
}

extension AnnotationViewControllerSettingsCategory: SpotlightViewControllerDelegate {
    
    func spotlightViewControllerWillPresent(_ viewController: SpotlightViewController, animated: Bool) {
        next(false)
    }
    
    func spotlightViewControllerTapped(_ viewController: SpotlightViewController, tappedSpotlight: SpotlightType?) {
        next(true)
    }
    
    func spotlightViewControllerWillDismiss(_ viewController: SpotlightViewController, animated: Bool) {
        spotlightView.disappear()
    }
}

private extension AnnotationViewControllerSettingsCategory {
    
    func setupAnnotationViewPosition() {
        let rightBarButtonFrames = extractRightBarButtonConvertedFrames()
        annotationViews.enumerated().forEach { (offset, annotationView) in
            switch offset {
            case 0:
                annotationView.frame.origin.x = (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)! - annotationView.frame.size.width
                annotationView.frame.origin.y = rightBarButtonFrames.origin.y + 60
            default:
                fatalError("unexpected index \(offset) for \(annotationView)")
            }
        }
    }
    
    var navigationBarHeight: CGFloat { 44 }
    var viewControllerHasNavigationItem: UIViewController? {
        if let controller = presentingViewController as? UINavigationController {
            if controller.viewControllers[0] is SettingsCategoryTableViewController {
                return controller.viewControllers[0]
            } else {
                print(controller.viewControllers[0]) // SettingsTableViewController
                print(controller.viewControllers[1]) // UINavigationController
                return controller.viewControllers[1]
            }
        }
        return presentingViewController
    }

    func extractRightBarButtonConvertedFrames() -> (CGRect) {
        guard
            let first  = viewControllerHasNavigationItem?.view.viewWithTag(0)?.viewWithTag(1)
        else {
            fatalError("Unexpected extract view from UIBarButtonItem via value(forKey:)")
        }
        return first.convert(first.bounds, to: view)
    }
}
