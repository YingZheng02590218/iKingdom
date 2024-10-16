//
//  AnnotationViewControllerJournals.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/11/20.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Gecco
import UIKit

class AnnotationViewControllerJournals: SpotlightViewController {

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
                [
                    Spotlight.RoundedRect(
                        center: CGPoint(x: rightBarButtonFrames.first.midX, y: rightBarButtonFrames.first.midY),
                        size: CGSize(width: rightBarButtonFrames.first.width, height: rightBarButtonFrames.first.height),
                        cornerRadius: 6
                    ),
                    Spotlight.Oval(
                        center: CGPoint(x: rightBarButtonFrames.second.midX, y: rightBarButtonFrames.second.midY),
                        diameter: 50
                    )
                ]
            )
        case 1:
            spotlightView.move(
                Spotlight.RoundedRect(
                    center: CGPoint(x: rightBarButtonFrames.first.midX, y: rightBarButtonFrames.first.midY),
                    size: CGSize(width: rightBarButtonFrames.first.width, height: rightBarButtonFrames.first.height),
                    cornerRadius: 6
                ),
                moveType: .direct
            )
        case 2:
            spotlightView.move(
                Spotlight.Oval(center: CGPoint(x: rightBarButtonFrames.second.midX, y: rightBarButtonFrames.second.midY), diameter: 50),
                moveType: .direct
            )
        case 3:
            spotlightView.move(
                Spotlight.RoundedRect(
                    center: CGPoint(x: rightBarButtonFrames.third.midX, y: rightBarButtonFrames.third.midY),
                    size: CGSize(width: rightBarButtonFrames.third.width, height: rightBarButtonFrames.third.height),
                    cornerRadius: 6
                ),
                moveType: .direct
            )
            if let third = tableViewControllerHasCell?.view.viewWithTag(0)?.viewWithTag(33) as? UITableViewCell {
                self.view.isUserInteractionEnabled = false
                // TableViewのスワイプアクションの擬似的なアニメーション
                UIView.animateRevealHideActionForRow(cell: third) {
                    self.view.isUserInteractionEnabled = true
                }
            }
        case 4:
            spotlightView.move(
                Spotlight.RoundedRect(
                    center: CGPoint(x: rightBarButtonFrames.third.midX, y: rightBarButtonFrames.third.midY),
                    size: CGSize(width: rightBarButtonFrames.third.width, height: rightBarButtonFrames.third.height),
                    cornerRadius: 6
                ),
                moveType: .disappear
            )
        case 5:
            spotlightView.move(
                Spotlight.RoundedRect(
                    center: CGPoint(x: rightBarButtonFrames.fifth.midX, y: rightBarButtonFrames.fifth.midY),
                    size: CGSize(width: rightBarButtonFrames.fifth.width, height: rightBarButtonFrames.fifth.height),
                    cornerRadius: 6
                ),
                moveType: .direct
            )
            if let fifth = tableViewControllerHasCell?.view.viewWithTag(0)?.viewWithTag(333) as? UITableView {
                self.view.isUserInteractionEnabled = false
                // TableViewのドラッグアクションの擬似的なアニメーション
                UIView.animateRevealHideActionForTable(tableView: fifth) {
                    self.view.isUserInteractionEnabled = true
                }
            }
        case 6:
            spotlightView.appear(
                Spotlight.Oval(
                    center: CGPoint(x: rightBarButtonFrames.forth.midX, y: rightBarButtonFrames.forth.midY),
                    diameter: 50
                )
            )
        case 7:
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

extension AnnotationViewControllerJournals: SpotlightViewDelegate {
    
    func spotlightWillAppear(spotlightView: SpotlightView, spotlight: SpotlightType) {
        print("\(#function): \(spotlight)")
    }
    func spotlightWillMove(spotlightView: SpotlightView, spotlight: (from: SpotlightType, to: SpotlightType), moveType: SpotlightMoveType) {
        print("\(#function): \(spotlight) is gecco spotlight?: \((spotlight.to as? Spotlight.Oval) == geccoSpotlight)")
    }
}

extension AnnotationViewControllerJournals: SpotlightViewControllerDelegate {
    
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

private extension AnnotationViewControllerJournals {
    
    func setupAnnotationViewPosition() {
        let rightBarButtonFrames = extractRightBarButtonConvertedFrames()
        annotationViews.enumerated().forEach { (offset, annotationView) in
            switch offset {
            case 0:
                annotationView.frame.origin.x = (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)! - annotationView.frame.size.width
                annotationView.frame.origin.y = rightBarButtonFrames.first.origin.y + 60
            case 1:
                annotationView.frame.origin.x = (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)! - annotationView.frame.size.width
                annotationView.frame.origin.y = rightBarButtonFrames.first.origin.y + 60
            case 2:
                annotationView.frame.origin.x = (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)! - annotationView.frame.size.width
                annotationView.frame.origin.y = rightBarButtonFrames.second.origin.y + 60
            case 3:
                annotationView.frame.origin.x = (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)! - annotationView.frame.size.width
                annotationView.frame.origin.y = rightBarButtonFrames.third.origin.y + 20 + rightBarButtonFrames.third.height
            case 4:
                annotationView.frame.origin.x = (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)! - annotationView.frame.size.width
                annotationView.frame.origin.y = rightBarButtonFrames.third.origin.y + 20 + rightBarButtonFrames.third.height
            case 5:
                annotationView.frame.origin.x = (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)! - annotationView.frame.size.width
                annotationView.frame.origin.y = rightBarButtonFrames.fifth.origin.y + 20 + rightBarButtonFrames.fifth.height
            case 6:
                annotationView.frame.origin.x = (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)! - annotationView.frame.size.width
                annotationView.frame.origin.y = rightBarButtonFrames.forth.origin.y + 20 + rightBarButtonFrames.forth.height
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
                let viewControllerTB = controller.viewControllers[1]
                print(viewControllerTB)
                return controller.viewControllers[1]
            }
            print(controller.viewControllers[0])
            return controller.viewControllers[0]
        }
        return presentingViewController
    }
    // テーブルビューのセルを取得
    var tableViewControllerHasCell: UIViewController? {
        if let controller = presentingViewController as? UINavigationController {
            if controller.viewControllers[0] is JournalsViewController {
                return controller.viewControllers[0]
            }
            print(controller.viewControllers[0])
            return controller.viewControllers[0]
        }
        return presentingViewController
    }

    func extractRightBarButtonConvertedFrames() -> (first: CGRect, second: CGRect, third: CGRect, fifth: CGRect, forth: CGRect) {
        guard
            let first  = tableViewControllerHasCell?.view.viewWithTag(0)?.viewWithTag(55),
            let second = viewControllerHasNavigationItem?.navigationItem.rightBarButtonItems?[1].value(forKey: "view") as? UIView,
            let third  = tableViewControllerHasCell?.view.viewWithTag(0)?.viewWithTag(33),
            let fifth  = tableViewControllerHasCell?.view.viewWithTag(0)?.viewWithTag(333),
            let forth  = viewControllerHasNavigationItem?.navigationItem.rightBarButtonItems?[0].value(forKey: "view") as? UIView
        else {
            fatalError("Unexpected extract view from UIBarButtonItem via value(forKey:)")
        }
        return (
            first: first.convert(first.bounds, to: view),
            second: second.convert(second.bounds, to: view),
            third: third.convert(third.bounds, to: view),
            fifth: fifth.convert(fifth.bounds, to: view),
            forth: forth.convert(forth.bounds, to: view)
        )
    }
}
