import UIKit

class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        #if DEBUG
            showTestPageViewController()
        #else
            showMainViewController()
        #endif
    }
    
    private func showTestPageViewController() {
        let coordinator = TestPageCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
        coordinator.delegate = self
        coordinator.start()
    }
    
    private func showMainViewController() {
        let coordinator = MainCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
}

extension AppCoordinator: TestPageCoordinatorDelegate {
    func didMainIn(_ coordinator: TestPageCoordinator) {
        self.childCoordinators = childCoordinators.filter { $0 !== coordinator }
        showMainViewController()
    }
}
