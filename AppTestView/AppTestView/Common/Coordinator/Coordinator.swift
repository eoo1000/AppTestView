//
//  File.swift
//  AppTestView
//
//  Created by eoo on 6/25/25.
//

import Foundation

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}
