//
//  BackgroundViewFactoryImpl.swift
//  OCM
//
//  Created by Carlos Vicente on 30/10/2018.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import UIKit
import OCMSDK

struct BackgroundViewFactoryImpl: BackgroundViewFactory {
    func createView() -> UIView {
        let backgroundView = BackgroundColorHour(frame: .zero)
        backgroundView.tonalityName = Tonality.light.rawValue
        return backgroundView
    }
}
