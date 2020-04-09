//
//  ViewController.swift
//  NarrowScreen
//
//  Created by s-huang on 2020/01/31.
//  Copyright © 2020 U-Next. All rights reserved.
//

import UIKit

class Cell: UITableViewCell {
    let colors: [UIColor] = [.red, .yellow, .cyan, .blue, .gray, .green, .orange, .brown]
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = colors.randomElement()!
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UIViewController {
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.backgroundColor = .lightGray
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(Cell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        tableView.reloadData()
    }

    override func viewSafeAreaInsetsDidChange() {
//        print("View controller: \(traitCollection) \(view.safeAreaInsets) window \(view.window?.safeAreaInsets)")
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    var transitionDelegate = TransitionDelegate()
    var triggerView: UIView?
    var snapshot: UIView?
    var triggerFrame: CGRect?
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? Cell else {
            fatalError("Wrong type of cell")
        }
        cell.textLabel?.text = "label \(indexPath.row)"
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        triggerView = cell?.snapshotView(afterScreenUpdates: false)
        triggerView?.frame = tableView.convert(cell!.frame, to: view)
        triggerFrame = tableView.convert(cell!.frame, to: view)

        snapshot = view.snapshotView(afterScreenUpdates: false)


        let vc = PlayerViewController()
        vc.transitioningDelegate = transitionDelegate
        vc.modalPresentationStyle = .custom
        vc.view.backgroundColor = cell?.contentView.backgroundColor
        self.present(vc, animated: true, completion: nil)


        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 1)
        self.additionalSafeAreaInsets = .zero
    }
}

class PlayerViewController: UIViewController {
    var closeAction: (() -> Void)?
    lazy var button: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btn)
        btn.setTitle("Close me", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(closeBtnPressed), for: .touchUpInside)
        return btn
    }()

    @objc func closeBtnPressed() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        modalPresentationStyle = .fullScreen
        self.view.backgroundColor = UIColor.cyan
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

}

class TransitionController: UIPresentationController {

    override func presentationTransitionDidEnd(_ completed: Bool) {

    }
    override func presentationTransitionWillBegin() {
    }

    override func dismissalTransitionWillBegin() {
        print((presentingViewController as? ViewController)?.tableView.visibleCells.first?.frame)
        print(presentingViewController.view.frame, presentingViewController.view.safeAreaInsets)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        let orientation = presentingViewController.preferredInterfaceOrientationForPresentation
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }

    override var shouldRemovePresentersView: Bool {
        return true
    }
    override var shouldPresentInFullscreen: Bool {
        return true
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
}

class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let dismiss: Bool
    init(dismiss: Bool) {
        self.dismiss = dismiss
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let presentingViewController = transitionContext.viewController(forKey: .from)!
        let presentedViewController = transitionContext.viewController(forKey: .to)!
        let containerView = transitionContext.containerView
        if !dismiss {
            if let vc = (presentingViewController as? ViewController), let snapshot = vc.triggerView {

                vc.snapshot?.center = containerView.center
                vc.snapshot?.transform = CGAffineTransform.identity.rotated(by: -.pi/2)
                containerView.addSubview(vc.snapshot!)

                let wRatio = presentedViewController.view.frame.height/snapshot.frame.width
                let hRatio = presentedViewController.view.frame.width/snapshot.frame.height

                snapshot.transform = CGAffineTransform.identity.rotated(by: -.pi/2)
                snapshot.frame = CGRect(x: vc.triggerFrame!.minY, y: 0, width: snapshot.frame.width, height: snapshot.frame.height)

                containerView.addSubview(snapshot)

                let xOffset = snapshot.center.x - presentedViewController.view.center.x
                let yOffset = snapshot.center.y - presentedViewController.view.center.y

                UIView.animate(withDuration: 1, animations: {
                    let transform = CGAffineTransform.identity
//                                        .translatedBy(x: -yOffset, y: -xOffset)
                                        .scaledBy(x: wRatio, y: hRatio)
//                                        .rotated(by: .pi/2)
                    var f = snapshot.frame
                    f.origin = CGPoint(x: containerView.center.x-20, y: 0)
                    snapshot.frame = f

                    snapshot.transform = transform
                }, completion: { finished in
                    presentedViewController.view.frame = CGRect(origin: .zero, size: UIScreen.main.bounds.size)
                    transitionContext.containerView.addSubview(presentedViewController.view)
                    transitionContext.completeTransition(finished)
                    snapshot.removeFromSuperview()
                    vc.snapshot?.removeFromSuperview()
                })
            }

        } else {
            presentedViewController.view.alpha = 0
            transitionContext.containerView.addSubview(presentedViewController.view)
            UIView.animate(withDuration: 0.3, animations: {
                presentingViewController.view.alpha = 0
                presentedViewController.view.alpha = 1.0

            }, completion: { finished in
                transitionContext.completeTransition(finished)
            })
        }



    }
}

class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return TransitionController(presentedViewController: presented, presenting: presenting)
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionAnimator(dismiss: false)
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionAnimator(dismiss: true)
    }
}
