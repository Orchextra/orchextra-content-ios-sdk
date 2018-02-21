//
//  ActionInteractorTests.swift
//  OCMTests
//
//  Created by Eduardo Parada on 7/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//


import Foundation
import Quick
import Nimble
import GIGLibrary
@testable import OCMSDK

class ActionInteractorSpec: QuickSpec {
    
    // MARK: - Attributes
    var interactor: ActionInteractor!
    var elementServiceMock: ElementServiceMock!
    
    override func spec() {
        beforeEach {
            self.elementServiceMock = ElementServiceMock()
            self.interactor = ActionInteractor(
                contentDataManager: ContentDataManager(
                    contentPersister: ContentCoreDataPersister.shared,
                    menuService: MenuService(),
                    elementService: self.elementServiceMock,
                    contentListService: ContentListService(),
                    contentVersionService: ContentVersionService(),
                    contentCacheManager: ContentCacheManager.shared,
                    offlineSupportConfig: Config.offlineSupportConfig,
                    reachability: ReachabilityWrapper.shared
                ),
                ocmController:  OCMController(),
                actionScheduleManager: ActionScheduleManager()
            )
        }
        
        afterEach {
            self.interactor = nil
        }
        
        describe("when launch action") {
            
            context("from Network was success") {
                beforeEach {
                    self.elementServiceMock.action = ActionWebview(url: URL(string: "http://gigigo.com")!, federated: nil, preview: nil, shareInfo: nil, slug: "slug")
                }
                
                it("get action") {
                    self.interactor.action(forcingDownload: true, with: "identifier", completion: { (action, error) in
                        if let action = action as? ActionWebview, let lastAction = self.elementServiceMock.action as? ActionWebview {
                            expect(action.slug).toEventually(equal(lastAction.slug))
                        } else if let error = error as NSError? {
                            expect(error.domain).toEventuallyNot(equal("BadError"))
                        }
                    })
                }
            }
            
            context("from Network was error") {
                beforeEach {
                    self.elementServiceMock.error = NSError(domain: "domain", code: 1, message: "Error service")
                }
                
                it("get error") {
                    self.interactor.action(forcingDownload: true, with: "identifier", completion: { (action, error) in
                        if let action = action as? ActionWebview, let lastAction = self.elementServiceMock.action as? ActionWebview {
                            expect(action.slug).toEventually(equal(lastAction.slug))
                        } else if let error = error as NSError? {
                            expect(error.domain).toEventuallyNot(equal("BadError"))
                            expect(error.code).toEventually(equal(self.elementServiceMock.error?.code))
                        }
                    })
                }
            }
        }
    }
}
