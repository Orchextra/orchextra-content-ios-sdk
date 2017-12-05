# Orchextra Content Manager for iOS

----
![Language](https://img.shields.io/badge/Language-Swift-orange.svg)
![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/Orchextra/orchextra-content-ios-sdk.svg?branch=master)](https://travis-ci.org/Orchextra/orchextra-content-ios-sdk)

## Getting started

Start by creating a project in [Orchextra dashboard][dashboard], if you haven't done it yet. Go to "Settings" > "SDK Configuration" to obtain the **api key** and **api secret** values for your project. You will need these values to configure and integrate the OCM SDK.

## How to add it to my project?

Using Carthage dependency manager.

### Install Carthage

Run the following commands in a terminal:

```
brew update && brew install carthage
```

### Add the dependency to the Cartfile

Create (if you haven't yet) a file called "Cartfile" in the root folder of your project, and add the following line to the file:

```
github "Orchextra/orchextra-content-ios-sdk" ~> 2.0
```

### Update the dependencies

Run the following command in your terminal (you should locate at your project root folder):

```
carthage update --cache-builds
```

> More information about using Carthage: https://github.com/Carthage/Carthage

## Integrate OCM SDK

First of all, you'll need to configure the OCM SDK with your project properties and start Orchextra calling the `start(apiKey: String, apiSecret: String, completion: Closure)`. For the latter, you'll need to get the **APIKEY** and the **APISECRET** for your project at the Orchextra Dashboard. 

The following is an example of how to configure OCM SDK from your project:

``` swift
func startOrchextraContentManager() {
	let ocm = OCM.shared

	// Configure Orchextra host
	ocm.orchextraHost = "https://sdk.orchextra.io"

	// Configure OCM host
	ocm.host = "https://cm.orchextra.io"

	// Set OCM delegate
	ocm.delegate = self

	// Set other project properties (optional)
	ocm.logLevel = .debug
	// ...

	// Start OCM
	orchextra.start(apiKey: APIKEY, apiSecret: APISECRET) { result in 
		// Check if Orchextra's start succeeded or failed
	}
}
```

## Usage

Orchextra's content is composed of a set of **Menus**. Each **Menu** contains an array of **Sections**, and the latter includes a set of **Contents**. You'll be able to setup all of these contents from the Orchextra Dashboard.

In order to display and handle the content from OCM you'll need to comply to the **OCMDelegate** protocol, but **first** you'll need to call the `loadMenus()` method when initializing the library as follows: 

``` swift
func startOrchextraContentManager() {
	let ocm = OCM.shared
	// OCM configuration
	// ...
	// Set OCM delegate
	ocm.delegate = self
	// Start OCM
	orchextra.start(apiKey: APIKEY, apiSecret: APISECRET) { result in 
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

The `openAction()` method returns an **OrchextraViewController**, containing the view heriarchy defined in the dashboard for that content in particular.

If you need to embed the **OrchextraViewController** inside your own **UIViewController**, it's recommended you do it using autolayout (to prevent errors with animations) and set it as the child ViewController, as shown below:

``` swift
// As you set up your ViewController, set OCM's result ViewController as it's child
self.addChildViewController(viewController)
// Add the view with autolayout wrapping constraints
self.view.addSubviewWithAutolayout(viewController.view)
// Inform OCM's result ViewController that there's a change on the hierarchy
viewController.didMove(toParentViewController: self)
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

In order to customize the style for OCM, the library offers some variables for this purpose:

#### From version 1.0.0

``` swift 
/// Use it to set an image wich indicates that something is being loaded but it has not been downloaded yet.
var loadingView: StatusView? 
    
/// Use it to set a custom view that will be shown when there will be no content.
var noContentView: StatusView? 
	
/// Use it to set a custom view that will be shown when there will be no content associated to a search.
var noSearchResultView: StatusView? 
``` 

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

#### From version 2.0.0

```swift
/// Use it to set an error view that will be shown when an error occurs.
var errorView: ErrorView?
```

### Strings

From version 2.0.0 if you want configure or localize strings shown by OCM SDK you have to set up them in a property that lists all the strings required by OCM:

```swift
OCM.shared.strings = Strings(
	...
)
```

### Language & Business Unit

``` swift
/// Use it to set the language code. It will be sent to server to get content in this language if it is available.
var languageCode: String?

/// Use it to set Orchextra device business unit
var businessUnit: String? 
``` 

### Authorization restriction

In Orchextra Dashboard, there is a way to set a content as "login restricted". You can configure the blocked content view that will be shown with this type of content.

``` swift
/**
 * Use it to set an image wich indicates that content is blocked.
 *
 - Since: 1.0
*/
var blockedContentView: StatusView? 
``` 

To notify OCM that the user is logged in into your application:

``` swift
OCM.shared.didLogin(with: IDENTIFIER)
``` 

Then, OCM will call this method of its OCMDelegate when the login finished

``` swift
func didUpdate(accessToken: String?)
``` 

OCM provides a way to notify that the content you are trying to open is login-restricted. Look the method on OCMDelegate:

``` swift
/**
Use this method to indicate that a content requires authentication to continue navigation.
Don't forget to call the completion block after calling the delegate method didLogin(with:) in case the login succeeds in order to perform any pending authentication-requires operations, such as navigating.

- Parameter completion: closure triggered when the login process finishes
- Since: 2.1.0
*/
func contentRequiresUserAuthentication(_ completion: @escaping () -> Void)

``` 

This could be an example of usage, OCM will open the content after the ending of the login process:

``` swift
func contentRequiresUserAuthentication(_ completion: @escaping () -> Void) {
	// Any login provider
	LoginProvider.login() { result in
		// ...
		OCM.shared.didLogin(with: result.UserID) // Send to OCM the UserID 
		completion() // Notify to OCM that the login process did finish
	}	
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