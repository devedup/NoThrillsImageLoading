# No Thrills Image Loading - Swift 3

[![Build Status](https://travis-ci.org/devedup/NoThrillsImageLoading.svg?branch=master)](https://travis-ci.org/devedup/NoThrillsImageLoading)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/NoThrillsImageLoading.svg)](https://img.shields.io/cocoapods/v/NoThrillsImageLoading.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/NoThrillsImageLoading.svg?style=flat)](http://cocoadocs.org/docsets/NoThrillsImageLoading)

# Goals

I wanted an image loading library that did cached image loading, with cancelable requests and nothing more. This is what I achieved with 'No Thrills Image Loading'. 

If you would rather have some thrills, such as filters, transitions, scaling, rounding, response serializers, etc etc ... then take a look at [Alamofire Image](https://github.com/Alamofire/AlamofireImage). 

###Usage

#### Load an image into your UIImageView

```swift

let imageURL = NSURL(string:"http://www.mysite.com/image.png")!
imageView.loadFrom(imageURL)

```


