# Orchextra Content Manager for iOS

----
![Language](https://img.shields.io/badge/Language-Swift-orange.svg)
![Version](https://img.shields.io/badge/version-1.0.3-blue.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/Orchextra/orchextra-content-ios-sdk.svg?branch=master)](https://travis-ci.org/Orchextra/orchextra-content-ios-sdk)

## Getting started

Start by creating a project in [Orchextra dashboard][dashboard], if you haven't done it yet. Go to "Setting" > "SDK Configuration" to get the **api key** and **api secret**, you will need these values to start Orchextra SDK.

## How to add it to my project?

Through Carthage


### Install Carthage

Run the following commands in a terminal

```
brew update && brew install carthage
```

### Add the dependency to the Cartfile

Create (if you didn't yet) a file called "Cartfile" in the root folder of your project, and add the following line

```
github "Orchextra/orchextra-content-ios-sdk" ~> 1.0
```

### Update the dependencies

Run the following command in a terminal at your project root folder

```
carthage update --cache-builds
```

More Info about carthage: https://github.com/Carthage/Carthage

## Integrate OCM SDK

First of all, you need to configure OCM SDK with the basic configuration and then start Orchextra with APIKey and APISecret given in the Orchextra dashboard.

``` swift
func startOrchextraContentManager() {
	let orchextra = Orchextra.sharedInstance()
	let ocm = OCM.shared
	// Configure OCM
	ocm.host = "https://cm.orchextra.io"
	ocm.logLevel = .debug
	// Configure Orchextra and start
	orchextra.setApiKey(APIKEY, apiSecret: APISECRET) { success, error in 
		// Check here if error or success
	}
}
```

## Usage

The content is sectioned in Menus. Each **Menu** contains an array of **Sections** that it includes some content. To get all menus configured in Orchextra Dashboard:

``` swift
OCM.shared.menus { succeed, menus, error in
	if succeed {
		if menus.count > 0 {
			for menu in menus {
				// Here we can show the sections (by accessing menu.sections) in some table view or similar
			}
		}
	} else if let error = error {
		print(error)
	}
}
```

When you want to show the content of some **Section**, just do:

``` swift
let menu = menus.first
let viewController = menu?.sections[0]?.openAction()
if let viewController = viewController {
	self.present(viewController, animated: true)
}
```

It returns a **OrchextraViewController**, that contains the content view with the view heriarchy defined in the dashboard.

Maybe you need to embbed the OrchextraViewController inside your own ViewController. To do this, please add it with Autolayout (to prevent errors with animations) and set it as ChildViewController of your own ViewController class:

``` swift
let menu = menus.first
let viewController = menu?.sections[0]?.openAction()
if let viewController = viewController {
	 self.addChildViewController(viewController)
     self.searchContainer.addSubviewWithAutolayout(viewController.view)
     viewController.didMove(toParentViewController: self)
}
```

## Advanced

### Search content

There is a way to create an empty OrchextraViewController with the purpose of search some content 

``` swift
let searchViewController = OCM.shared.searchViewController()
if let searchViewController = viewController {
	self.addChildViewController(searchViewController)
	self.searchContainer.addSubviewWithAutolayout(searchViewController.view)
	searchViewController.didMove(toParentViewController: self)
	searchViewController.search(byString: "Text to search")
}
```

### Customize style

In order to customize your OCM style, it offers some variables for this purpose:

``` swift
/**
 * Use it to set a preview that is shown while asynchronous image is loading.
 *
 - Since: 1.0
 */
public var placeholder: UIImage? {
	didSet {
		Config.placeholder = self.placeholder
	}
}
    
/**
 * Use it to set an image wich indicates that something is being loaded but it has not been downloaded yet.
 *
 - Since: 1.0
 */
public var loadingView: StatusView? {
    didSet {
        Config.loadingView = self.loadingView
    }
}
    
/**
 * Use it to set a content list background color. It allows avoid whitespaces by using application custom color.
 *
 - Since: 1.0
 */
public var contentListBackgroundColor: UIColor? {
    didSet {
        Config.contentListBackgroundColor = self.contentListBackgroundColor
    }
}
    
/**
 * Use it to set a content list margin color.
 *
 - Since: 1.0
 */
public var contentListMarginsColor: UIColor? {
    didSet {
        Config.contentListMarginsColor = self.contentListMarginsColor
    }
}
    
/**
 * Use it to set a custom view that will be shown when there will be no content.
 *
 - Since: 1.0
 */
public var noContentView: StatusView? {
	didSet {
		Config.noContentView = self.noContentView
	}
}
	
/**
 * Use it to set a custom view that will be shown when there will be no content associated to a search.
 *
 - Since: 1.0
 */
public var noSearchResultView: StatusView? {
    didSet {
        Config.noSearchResultView = self.noSearchResultView
    }
}
    
/**
 * Use it to instantiate ErrorView clasess that will be shown when an error occurs.
 *
 - Since: 1.0
 */
public var errorViewInstantiator: ErrorView.Type? {
    didSet {
        Config.errorView = self.errorViewInstantiator
    }
}
``` 
### Language

``` swift
/**
 * Use it to set a language code. It will be sent to server to get content in this language if it is available.
 *
 - Since: 1.0
 */
public var languageCode: String? {
    didSet {
        Session.shared.languageCode = self.languageCode
    }
}
``` 

### Authotization restriction

In Orchextra Dashboard, there is a way to set a content as "login restricted". You can configure the blocked content view that will be shown with this type of content.

``` swift
/**
 * Use it to set an image wich indicates that content is blocked.
 *
 - Since: 1.0
*/
public var blockedContentView: StatusView? {
    didSet {
        Config.blockedContentView = self.blockedContentView
    }
}
``` 

To notify OCM that the user is logged in your application:

``` swift
OCM.shared.isLogged = true
OCM.shared.userID = "THE USER ID INFORMATION"
``` 

Then, OCM will call this method of its OCMDelegate when the login finished

``` swift
func didUpdate(accessToken: String?)
``` 

[dashboard]: https://dashboard.orchextra.io
