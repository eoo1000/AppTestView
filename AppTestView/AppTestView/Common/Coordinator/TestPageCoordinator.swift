//
//  TestPageCoordinator.swift
//  AppTestView
//
//  Created by eoo on 6/25/25.
//

import UIKit

protocol TestPageCoordinatorDelegate {
    func didMainIn(_ coordinator: TestPageCoordinator)
}

class TestPageCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var delegate: TestPageCoordinatorDelegate?
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = TestPageViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func goMain() {
        delegate?.didMainIn(self)
    }
}
