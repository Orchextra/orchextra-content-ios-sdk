//
//  MenuCoordinatorSpec.swift
//  OCM
//
//  Created by José Estela on 14/2/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import Quick
import Nimble
import OHHTTPStubs
@testable import OCMSDK

class MenuCoordinatorSpec: QuickSpec {

    // MARK: - Attributes
    
    var menuCoordinator: MenuCoordinator!
    var sessionInteractorMock: SessionInteractorMock!
    
    // MARK: - Spec method
    
    override func spec() {
        
        describe("test menu coordinator") {
            
            beforeEach {
                self.sessionInteractorMock = SessionInteractorMock()
                self.menuCoordinator = MenuCoordinator(
                    sessionInteractor: self.sessionInteractorMock,
                    menuInteractor: MenuInteractor(
                        sessionInteractor: self.sessionInteractorMock,
                        contentDataManager: ContentDataManager(
                            contentPersister: ContentPersisterMock(),
                            menuService: MenuService(),
                            elementService: ElementService(),
                            contentListService: ContentListService()
                        )
                    )
                )
            }
            
            afterEach {
                self.menuCoordinator = nil
                self.sessionInteractorMock = nil
                OHHTTPStubs.removeAllStubs()
            }
            
            describe("when API response is success") {
                beforeEach {
                    ServiceHelper.mockResponse(for: "/menus", with: "menus_ok.json")
                }
                it("return menus in block") {
                    waitUntil(timeout: 5.0) { done in
                        self.menuCoordinator.menus { succeed, menu, error in
                            expect(succeed) == true
                            expect(menu.count) > 0
                            expect(error).to(beNil())
                            done()
                        }
                    }
                }
            }
            
            describe("when API response failure") {
                beforeEach {
                    ServiceHelper.mockResponse(for: "/menus", with: "response_ko.json")
                }
                it("return error content in block") {
                    waitUntil(timeout: 5.0) { done in
                        self.menuCoordinator.menus { succeed, menu, error in
                            expect(succeed) == false
                            expect(menu.count) == 0
                            expect(error).notTo(beNil())
                            done()
                        }
                    }
                }
            }
        }
    }
}
