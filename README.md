# Orchextra Content Manager for iOS

----
![Language](https://img.shields.io/badge/Language-Swift-orange.svg)
![Version](https://img.shields.io/badge/version-4.0.3-blue.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/Orchextra/orchextra-content-ios-sdk.svg?branch=master)](https://travis-ci.org/Orchextra/orchextra-content-ios-sdk)

## Getting started

Start by creating a project in [Orchextra Dashboard][dashboard], if you haven't done it yet. You'll need to get your project `APIKEY` and `APISECRET`  to configure and integrate OCM SDK, you can look them up in  [Orchextra dashboard][dashboard] by going to "Settings" -> "SDK Configuration".

## How to add it to my project?

Using Carthage dependency manager.

### Install Carthage

Run the following commands in a terminal:

```
brew update && brew install carthage
```

### Add the dependency to the Cartfile

Create (if you haven't yet) a file called `Cartfile` in the root folder of your project, and add the following line to the file:

```
github "Orchextra/orchextra-content-ios-sdk" ~> 3.0
```

### Update the dependencies

Run the following command in your terminal (you should locate at your project root folder):

```
carthage update --cache-builds --platform ios
```

> More information about using Carthage: https://github.com/Carthage/Carthage

### Requirements

* iOS 9.0+

### Swift & Xcode version support

| ORX Version | Swift Version | Xcode Version|
| :---: |:---:| :---:|
| **v3.x** | 3.x, 4.0, 4.1 | 9.x, 10.x |
| **v4.x** | 4.2 | 10.x |

## Integrate OCM SDK

First of all, you'll need to configure the OCM SDK with your project properties and start Orchextra calling the `start(apiKey: String, apiSecret: String, completion: Closure)`. For the latter, you'll need to get the `APIKEY` and the `APISECRET` for your project at the [Orchextra Dashboard][dashboard]. 

The following is an example of how to configure OCM SDK from your project:

``` swift
func startOrchextraContentManager() {
	let ocm = OCM.shared

	// Configure environment
	ocm.environment = .production

	// Start OCM
	ocm.start(apiKey: APIKEY, apiSecret: APISECRET) { result in 
		
	}
}
```

As you can see, OCM offers you a singleton instance (i.e.: `OCM.shared`), you should always use this singleton through your project.

## Usage

Orchextra's content is composed of a set of **Menus**. Each **Menu** contains an array of **Sections**, and the latter includes a set of **Contents**. You'll be able to setup all of these contents from the [Orchextra Dashboard][dashboard].

For initializing, you'll need to comply to the **ContentDelegate** protocol, after that, you can start to display contents from OCM by calling the `loadMenus()` method. The following snippet is an example of how you initialize: 

``` swift
func startOrchextraContentManager() {
	let ocm = OCM.shared
	// OCM configuration
	// ...
	// Set OCM delegate
	ocm.delegate = self
	// Start OCM
	ocm.start(apiKey: APIKEY, apiSecret: APISECRET) { 	
	result in 
	switch result {
    	case .success:
		// If start succeeds, load menus
		ocm.loadMenus()
    	case .error(let error):
		// If start fails, handle error
		// ...
        }
	}
}
```

For displaying the content, you'll need to comply to the `menusDidRefresh()` method from the **OCMDelegate** protocol, obtain your **menus** and show the corresponding **sections** by calling `openAction()` method as depicted by the following example:

``` swift
func menusDidRefresh(_ menus: [Menu]) {
	let menu = menus.first
	let sections = menu.sections
	for section in sections {
		section.openAction() { viewController in 
			// Show sections on your view layer
			// ...
		}
	}
}
```

The `openAction()` method returns an **OCMViewController**, containing the view heriarchy defined in the dashboard for that content in particular.

If you need to embed the **OCMViewController** inside your own **UIViewController**, it's recommended you do it using autolayout (to prevent errors with animations) and set it as the child ViewController, as shown below:

``` swift
// As you set up your ViewController, set OCM's result ViewController as it's child
self.addChildViewController(viewController)
// Add the view with autolayout wrapping constraints
self.view.addSubviewWithAutolayout(viewController.view)
// Inform OCM's result ViewController that there's a change on the hierarchy
viewController.didMove(toParentViewController: self)
```


### Search content

There is a way to create an empty ViewController with the purpose of search some content 

``` swift
let searchViewController = OCM.shared.searchViewController()
if let searchViewController = viewController {
	self.addChildViewController(searchViewController)
	self.searchContainer.addSubviewWithAutolayout(searchViewController.view)
	searchViewController.didMove(toParentViewController: self)
	searchViewController.search(byString: "Text to search")
}
```


## Advanced

### Language

``` swift
ocm.languageCode = "es"

```
### Business Unit

The business unit is the attribute defined in the OCM dashboard that provides the capability of handling multiple contents in the same project with a different source (for example, the country). If you want to filter the content by country, once you have some content linked to an specific Business Unit (for example, "it"), you can show this content by setting up the same value in the SDK with the following method: 

```swift
ocm.set(businessUnit: "it") {
	// The business unit is setted, you can request data now
	ocm.loadMenus()
}
``` 

If you want to show all the content, just avoid this step.

### Customize style

In order to customize the style for OCM, the library offers some variables for this purpose:

#### From version 1.1.7

```swift
/// Use it to customize style properties for UI controls and other components.
var styles: Styles?

/// Use it to customize style properties for the Content List.
var contentListStyles: ContentListStyles?

/// Use it to customize style properties for the Content List with a carousel layout.
var contentListCarouselLayoutStyles: ContentListCarouselLayoutStyles?

/// Use it to customize style properties for the Content Detail navigation bar.
var contentNavigationBarStyles: ContentNavigationBarStyles?
```

#### From version 4.0.3

```
/// Use it to customize style properties for the article content.
var articleStyles: ArticleStyles?
```

#### From version 3.0.0

Since 3.0.0 version, there is a delegate for customizing the custom views required by OCM SDK:

```swift
extension AnyClass: OCMSDK.CustomViewDelegate {
	
    func errorView(error: String, reloadBlock: @escaping () -> Void) -> UIView? {
    	/// Use it to set an error view that will be shown when an error occurs.
    	/// - Parameter error: The error message returned by OCM
    	/// - Parameter reloadBlock: Block called if you want to reload the data of the current content list errored
    }

    func loadingView() -> UIView? {
      	/// Use it to set an image wich indicates that something is being loaded but it has not been downloaded yet.
    }

    func noContentView() -> UIView? {
    	/// Use it to set a custom view that will be shown when there's no content.
    }

    func noResultsForSearchView() -> UIView? {
    	/// Use it to set a custom view that will be shown when there's no content associated to a search.
    }

    func newContentsAvailableView() -> UIView? {
    	/// Use it to set a view that will be show when new content is available.
    }
}

```

### Strings

From version 2.0.0 if you want configure or localize strings shown by OCM SDK you have to set up them in a property that lists all the strings required by OCM:

```swift
OCM.shared.strings = Strings(
	...
)
```

### Custom properties

In OCM Dashboard, you can add aditional data to every content / action / element in order to modify the behaviour or customizing it depeding on the value configured.

For this purpose, you have to conform the **CustomBehaviourDelegate** of OCMSDK and add some logic:

```swift
extension AnyClass: OCMSDK.CustomBehaviourDelegate {

	/// This method tells the delegate that a content with custom properties have to be validated/evaluated.
	/// - Parameter customProperties: Dictionary with custom properties information.
	/// - Parameter completion: Completion block to be triggered when content custom properties are validated, receives a `Bool` value representing the validation status, `true` for a succesful validation, otherwise `false`.
	func contentNeedsValidation(for customProperties: [String: Any], completion: @escaping (Bool) -> Void) {
	    // We are going to show the login process before opening the content if the user is not logged in
    	if let requiredAuth = customProperties["requiredAuth"] as? String, requiredAuth == "logged" {
    		// Any login provider
			LoginProvider.login() { result in
				// ...
				OCM.shared.didLogin(with: result.UserID) {
					completion(true)	// Notify to OCM that the login process did finish
				}
			}	
    	} else {
    		completion(false)
    	}
	}
	
	/// This method tells the delegate that a content with custom properties might need a view transformation to be applied.
    /// - Parameter content: Customizable content
    /// - Parameter completion: Completion block to be triggered when content custom properties are validated, receives a `CustomizableContent` value.
	func contentNeedsCustomization(_ content: CustomizableContent, completion: @escaping (CustomizableContent) -> Void) {
	    // We are going to modify the grid view if the content requires to be logged in
		if let requiredAuth = content.customProperties["requiredAuth"] as? String, requiredAuth == "logged" {
			if content.viewType == .gridContent {
				content.customizations = [.grayscale]
			}
		}
		completion(content)
	}
}
```

### Login / Logout

You can login / logout into OCM for restricting content depending on the user state:

``` swift
/// Use it to login into Orchextra environment. When the login process did finish, you will be notified in completion
ocm.didLogin(with userID: "USER_ID") {
	
} 

/// Use it to logout into Orchextra environment. When the logout process did finish, you will be notified in completion.
ocm.didLogout() {
	
} 
```

### Offline support

OCM offers an **Offline Mode** feature that allows access to the content with no Internet access. If you enable this feature, the last contents on **OCM's cache** will still be accessible even if Internet access is not available.

**OCM's cache** can be configured with the maximum elements that are cached (this values must be a positive number or zero):
- The maximum number of sections cached.
- The maximum number of elements per section cached.
- The maximum number of elements cached in the first section.

The **Offline Mode** feature is disabled by default. If you'd like to add this capability to your project you have to enable it **before start orchextra framework**  as follows:

``` swift
func startOrchextraContentManager() {
	let ocm = OCM.shared
	// OCM configuration
	// ...
	// Configure cached elements
	let offlineSupportConfig = OfflineSupportConfig(cacheSectionLimit: 10, cacheElementsPerSectionLimit: 6, cacheFirstSectionLimit: 12)
	// Enable offline support
	ocm.offlineSupportConfig = offlineSupportConfig
	// Start OCM
	orchextra.start(apiKey: APIKEY, apiSecret: APISECRET) { result in 
	// ...
	}
}
```

### Third-party providers

OCM offers a way to configure third-party services and providers by setting their configuration data through the following property:

```swift
OCM.shared.providers = ...
```

Currently supported providers are listed below::

#### VIMEO

1. Information needed by the SDK
	* **Access token**
2. How to configure in SDK:

```swift
let ocmProviders = Providers()
ocmProviders.vimeo = VimeoProvider(accessToken: "xxxxxxx")
OCM.shared.providers = ocmProviders
```


### Events information

To be informed about different events of interest occurring on OCM (e.g: content being loaded, content being shared, etc.) that could come in handy for handling analytics events, you'll need to conform to the protocol OCMEventDelegate. You can set this delegate as follows:

 
``` swift
OCM.shared.eventDelegate = self
```

And then you will receive information about the following events:

``` swift
/// Event triggered when the preview for a content loads on display.
func contentPreviewDidLoad(identifier: String, type: String)
    
/// Event triggered when a content loads on display.
func contentDidLoad(identifier: String, type: String)

/// Event triggered when a content is shared by the user.
func userDidShareContent(identifier: String, type: String)
    
/// Event triggered when a content is opened by the user.
func userDidOpenContent(identifier: String, type: String)
    
/// Event triggered when a video loads.
func videoDidLoad(identifier: String)

/// Event triggered when a section loads on display.
func sectionDidLoad(_ section: Section)
    
```

### Event Video

OCM offers a way to be informed about all video events like *play*, *stop* and *pause*. It's useful when you must handle audio like when the mute button is enabled. You'll need conform the OCMVideoEventDelegate protocol.

```swift
OCM.shared.videoEventDelegate = self
```

The following events are fired by this delegate:

```swift
/**
 Event triggered when a video starts or resumes
 */
func videoDidStart(identifier: String)
/**
 Event triggered when a video stops
 */
func videoDidStop(identifier: String)
/**
 Event triggered when a video pauses (restricted to >= iOS 10 when OCM plays vimeo videos)
*/
func videoDidPause(identifier: String)
```

[dashboard]: https://dashboard.orchextra.io

