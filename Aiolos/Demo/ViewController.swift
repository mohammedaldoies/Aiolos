//
//  ViewController.swift
//  Aiolos
//
//  Created by Matthias Tretter on 11/07/2017.
//  Copyright © 2017 Matthias Tretter. All rights reserved.
//

import UIKit
import Aiolos


final class ViewController: UIViewController {

    private lazy var panelController: PanelViewController = self.makePanelController()
    private lazy var lineView: UIView = self.makeLineView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Aiolos Demo"
        self.view.backgroundColor = .white

        let safeAreaView = UIView()
        safeAreaView.translatesAutoresizingMaskIntoConstraints = false
        safeAreaView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        self.view.addSubview(safeAreaView)
        NSLayoutConstraint.activate([
            safeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8.0),
            safeAreaView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 8.0),
            safeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -8.0),
            safeAreaView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -8.0)
        ])

        let textField = UITextField(frame: CGRect(x: 10.0, y: 74.0, width: 150.0, height: 44.0))
        textField.layer.borderWidth = 1.0
        textField.delegate = self
        self.view.addSubview(textField)
        self.view.addSubview(self.lineView)

        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(handleToggleVisibilityPress)),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleToggleModePress))
        ]

        self.panelController.add(to: self)
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        var configuration = self.panelController.configuration
        configuration.position = self.panelPosition(for: newCollection)
        configuration.margins = self.panelMargins(for: newCollection)

        coordinator.animate(alongsideTransition: { _ in
            self.panelController.configuration = configuration
        }, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

// MARK: - PanelSizeDelegate

extension ViewController: PanelSizeDelegate {

    func panel(_ panel: PanelViewController, sizeForMode mode: Panel.Configuration.Mode) -> CGSize {
        let width = self.panelWidth(for: self.traitCollection, position: panel.configuration.position)
        switch mode {
        case .compact:
            return CGSize(width: width, height: 64.0)
        case .expanded:
            return CGSize(width: width, height: 270.0)
        case .fullHeight:
            return CGSize(width: width, height: 0.0)
        }
    }
}

// MARK: - PanelAnimationDelegate

extension ViewController: PanelAnimationDelegate {

    func panel(_ panel: PanelViewController, willTransitionTo size: CGSize, with coordinator: PanelTransitionCoordinator) {
        // print("Will transition to \(size), animated: \(coordinator.isAnimated)")
//        coordinator.animateAlongsideTransition({
//            self.lineView.center = CGPoint(x: panel.view.center.x, y: panel.view.frame.minY - 5.0)
//        })
    }
}

// MARK: - Private

private extension ViewController {

    func makePanelController() -> PanelViewController {
        let configuration = Panel.Configuration.default
        let panelController = PanelViewController(configuration: configuration)
        let contentNavigationController = UINavigationController(rootViewController: PanelContentViewController(color: .clear))
        contentNavigationController.setToolbarHidden(false, animated: false)
        contentNavigationController.view.bringSubview(toFront: contentNavigationController.navigationBar)

        panelController.sizeDelegate = self
        panelController.animationDelegate = self
        panelController.contentViewController = contentNavigationController
        panelController.configuration.position = self.panelPosition(for: self.traitCollection)
        panelController.configuration.margins = self.panelMargins(for: self.traitCollection)

        if self.traitCollection.userInterfaceIdiom == .pad {
            panelController.configuration.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            panelController.configuration.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }

        return panelController
    }

    func makeLineView() -> UIView {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 1.0))
        view.backgroundColor = .red
        return view
    }

    func panelWidth(for traitCollection: UITraitCollection, position: Panel.Configuration.Position) -> CGFloat {
        if position == .bottom { return 0.0 }

        return traitCollection.userInterfaceIdiom == .pad ? 320.0 : 270.0
    }

    func panelPosition(for traitCollection: UITraitCollection) -> Panel.Configuration.Position {
        if traitCollection.userInterfaceIdiom == .pad { return .trailingBottom }

        return traitCollection.verticalSizeClass == .compact ? .leadingBottom : .bottom
    }

    func panelMargins(for traitCollection: UITraitCollection) -> UIEdgeInsets {
        if traitCollection.userInterfaceIdiom == .pad { return UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0) }

        let horizontalMargin: CGFloat = traitCollection.verticalSizeClass == .compact ? 20.0 : 0.0
        return UIEdgeInsets(top: 20.0, left: horizontalMargin, bottom: 0.0, right: horizontalMargin)
    }

    @objc
    func handleToggleVisibilityPress() {
        if self.panelController.isVisible {
            self.panelController.removeFromParent()
        } else {
            self.panelController.add(to: self)
        }
    }

    @objc
    func handleToggleModePress() {
        let nextModeMapping: [Panel.Configuration.Mode: Panel.Configuration.Mode] = [ .compact: .expanded,
                                                                                      .expanded: .fullHeight,
                                                                                      .fullHeight: .compact ]
        guard let nextMode = nextModeMapping[self.panelController.configuration.mode] else { return }

        self.panelController.configuration.mode = nextMode
    }
}
