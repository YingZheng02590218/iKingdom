//
//  AnnotationViewControllerJournalEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/11/18.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Gecco
import UIKit

class AnnotationViewControllerJournalEntry: SpotlightViewController {

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
                    center: CGPoint(x: rightBarButtonFrames.zero.midX, y: rightBarButtonFrames.zero.midY),
                    size: CGSize(width: rightBarButtonFrames.zero.width, height: rightBarButtonFrames.zero.height),
                    cornerRadius: 6
                )
            )
        case 1:
            spotlightView.appear(
                [
                    Spotlight.RoundedRect(
                        center: CGPoint(x: rightBarButtonFrames.firstRight.midX, y: rightBarButtonFrames.firstRight.midY),
                        size: CGSize(width: rightBarButtonFrames.firstRight.width, height: rightBarButtonFrames.firstRight.height),
                        cornerRadius: 6
                    ),
                    Spotlight.RoundedRect(
                        center: CGPoint(x: rightBarButtonFrames.firstLeft.midX, y: rightBarButtonFrames.firstLeft.midY),
                        size: CGSize(width: rightBarButtonFrames.firstLeft.width, height: rightBarButtonFrames.firstLeft.height),
                        cornerRadius: 6
                    )
                ]
            )
        case 2:
            spotlightView.appear(
                [
                    Spotlight.RoundedRect(
                        center: CGPoint(x: rightBarButtonFrames.secondRight.midX, y: rightBarButtonFrames.secondRight.midY),
                        size: CGSize(width: rightBarButtonFrames.secondRight.width, height: rightBarButtonFrames.secondRight.height),
                        cornerRadius: 6
                    ),
                    Spotlight.RoundedRect(
                        center: CGPoint(x: rightBarButtonFrames.secondLeft.midX, y: rightBarButtonFrames.secondLeft.midY),
                        size: CGSize(width: rightBarButtonFrames.secondLeft.width, height: rightBarButtonFrames.secondLeft.height),
                        cornerRadius: 6
                    )
                ]
            )
        case 3:
            spotlightView.move(
                Spotlight.RoundedRect(
                    center: CGPoint(x: rightBarButtonFrames.third.midX, y: rightBarButtonFrames.third.midY),
                    size: CGSize(width: rightBarButtonFrames.third.width, height: rightBarButtonFrames.third.height),
                    cornerRadius: 6
                ),
                moveType: .disappear
            )
        case 4:
            spotlightView.move(
                Spotlight.RoundedRect(
                    center: CGPoint(x: rightBarButtonFrames.forth.midX, y: rightBarButtonFrames.forth.midY),
                    size: CGSize(width: rightBarButtonFrames.forth.width, height: rightBarButtonFrames.forth.height),
                    cornerRadius: 6
                ),
                moveType: .disappear
            )
        case 5:
            DispatchQueue.main.async {
                if let navigationController = self.presentingViewController as? UINavigationController,
                   let presentingViewController = navigationController.viewControllers.first as? JournalEntryViewController {
                    self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                        // ViewController(コーチマーク画面)を閉じた時に、遷移元であるViewController(仕訳画面)で行いたい処理
                        // チュートリアル対応 コーチマーク型
                        presentingViewController.finishAnnotation()
                    })
                }
            }
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

extension AnnotationViewControllerJournalEntry: SpotlightViewDelegate {
    
    func spotlightWillAppear(spotlightView: SpotlightView, spotlight: SpotlightType) {
        print("\(#function): \(spotlight)")
    }
    func spotlightWillMove(spotlightView: SpotlightView, spotlight: (from: SpotlightType, to: SpotlightType), moveType: SpotlightMoveType) {
        print("\(#function): \(spotlight) is gecco spotlight?: \((spotlight.to as? Spotlight.Oval) == geccoSpotlight)")
    }
}

extension AnnotationViewControllerJournalEntry: SpotlightViewControllerDelegate {
    
    func spotlightViewControllerWillPresent(_ viewController: SpotlightViewController, animated: Bool) {
        next(false)
    }
    
    func spotlightViewControllerTapped(_ viewController: SpotlightViewController, tappedSpotlight: SpotlightType?) {
        next(true)
    }
    
    func spotlightViewControllerWillDismiss(_ viewController: SpotlightViewController, animated: Bool) {
        print(stepIndex)
        switch stepIndex {
        case 6:
            // スポットライトが小書きに当たっている時にダブルタップすると、クラッシュが発生していた対策
            break
        default:
            spotlightView.disappear()
        }
    }
}

private extension AnnotationViewControllerJournalEntry {
    
    func setupAnnotationViewPosition() {
        if let width = (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width) {
            let rightBarButtonFrames = extractRightBarButtonConvertedFrames()
            annotationViews.enumerated().forEach { offset, annotationView in
                switch offset {
                case 0:
                    annotationView.frame.origin.x = width - annotationView.frame.size.width
                    annotationView.frame.origin.y = rightBarButtonFrames.zero.origin.y + rightBarButtonFrames.zero.height + 20
                case 1:
                    annotationView.frame.origin.x = width - annotationView.frame.size.width
                    annotationView.frame.origin.y = rightBarButtonFrames.firstLeft.origin.y + rightBarButtonFrames.firstLeft.height + 20
                case 2:
                    annotationView.frame.origin.x = width - annotationView.frame.size.width
                    annotationView.frame.origin.y = rightBarButtonFrames.secondLeft.origin.y + rightBarButtonFrames.secondLeft.height + 20
                case 3:
                    annotationView.frame.origin.x = width - annotationView.frame.size.width
                    annotationView.frame.origin.y = rightBarButtonFrames.third.origin.y + rightBarButtonFrames.third.height + 20
                case 4:
                    annotationView.frame.origin.x = width - annotationView.frame.size.width
                    annotationView.frame.origin.y = rightBarButtonFrames.forth.origin.y + rightBarButtonFrames.forth.height + 20
                default:
                    fatalError("unexpected index \(offset) for \(annotationView)")
                }
            }
        }
    }
    
    var navigationBarHeight: CGFloat { 44 }
    var viewController: UIViewController? {
        if let controller = presentingViewController as? JournalEntryViewController {
            print(controller)
            return controller
        }
        return presentingViewController
    }
    
    func extractRightBarButtonConvertedFrames() -> (zero: CGRect, firstLeft: CGRect, firstRight: CGRect, secondLeft: CGRect, secondRight: CGRect, third: CGRect, forth: CGRect) {
        guard
            let zero        = viewController?.view.viewWithTag(1)?.viewWithTag(11)?.viewWithTag(111)?.viewWithTag(2_222) as? UIDatePicker,
            let firstLeft   = viewController?.view.viewWithTag(1)?.viewWithTag(22)?.viewWithTag(3_333)?.viewWithTag(11_111)?.viewWithTag(111) as? PickerTextField,
            let firstRight  = viewController?.view.viewWithTag(1)?.viewWithTag(22)?.viewWithTag(3_333)?.viewWithTag(11_111)?.viewWithTag(222) as? PickerTextField,
            let secondLeft  = viewController?.view.viewWithTag(1)?.viewWithTag(22)?.viewWithTag(3_333)?.viewWithTag(22_222)?.viewWithTag(333) as? UITextField,
            let secondRight = viewController?.view.viewWithTag(1)?.viewWithTag(22)?.viewWithTag(3_333)?.viewWithTag(22_222)?.viewWithTag(444) as? UITextField,
            let third       = viewController?.view.viewWithTag(1)?.viewWithTag(33)?.viewWithTag(555) as? UITextField,
            let forth       = viewController?.view.viewWithTag(1)?.viewWithTag(44)?.viewWithTag(555)?.viewWithTag(444) as? UIButton
        else {
            fatalError("Unexpected extract view from UIBarButtonItem via value(forKey:)")
        }
        return (
            zero: zero.convert(zero.bounds, to: view),
            firstLeft: firstLeft.convert(firstLeft.bounds, to: view),
            firstRight: firstRight.convert(firstRight.bounds, to: view),
            secondLeft: secondLeft.convert(secondLeft.bounds, to: view),
            secondRight: secondRight.convert(secondRight.bounds, to: view),
            third: third.convert(third.bounds, to: view),
            forth: forth.convert(forth.bounds, to: view)
        )
    }
}
