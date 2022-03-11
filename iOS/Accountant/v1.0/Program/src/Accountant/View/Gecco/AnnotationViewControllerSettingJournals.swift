//
//  AnnotationViewControllerSettingJournals.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/03/11.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import UIKit
import Gecco

class AnnotationViewControllerSettingJournals: SpotlightViewController {

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

extension AnnotationViewControllerSettingJournals: SpotlightViewDelegate {
    func spotlightWillAppear(spotlightView: SpotlightView, spotlight: SpotlightType) {
        print("\(#function): \(spotlight)")
    }
    func spotlightWillMove(spotlightView: SpotlightView, spotlight: (from: SpotlightType, to: SpotlightType), moveType: SpotlightMoveType) {
        print("\(#function): \(spotlight) is gecco spotlight?: \((spotlight.to as? Spotlight.Oval) == geccoSpotlight)")
    }
}

extension AnnotationViewControllerSettingJournals: SpotlightViewControllerDelegate {
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

private extension AnnotationViewControllerSettingJournals {
    func setupAnnotationViewPosition() {
        let rightBarButtonFrames = extractRightBarButtonConvertedFrames()
        annotationViews.enumerated().forEach { (offset, annotationView) in
            switch offset {
            case 0:
                annotationView.frame.origin.x = (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)! - annotationView.frame.size.width - 20
                annotationView.frame.origin.y = rightBarButtonFrames.origin.y + 60
            default:
                fatalError("unexpected index \(offset) for \(annotationView)")
            }
        }
    }
    
    // テーブルビューのセルを取得
    var tableViewControllerHasCell: UIViewController? {
        if let controller = presentingViewController as? UINavigationController,
           let navigationController = controller.viewControllers[1]  as? UINavigationController {
            for controller in navigationController.viewControllers {
                print("####", controller)
                if controller is SettingsOperatingTableViewController {
                    return controller
                }
            }
        }
        print(presentingViewController)
        return presentingViewController
    }

    func extractRightBarButtonConvertedFrames() -> CGRect {
        guard
            let first = tableViewControllerHasCell?.view.viewWithTag(0)!.viewWithTag(33)
            else {
                fatalError("Unexpected extract view from UIBarButtonItem via value(forKey:)")
        }
        return first.convert(first.bounds, to: view)
    }
}
