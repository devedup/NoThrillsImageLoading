# No Thrills Image Loading - Swift 5

[![Build Status](https://travis-ci.org/devedup/NoThrillsImageLoading.svg?branch=master)](https://travis-ci.org/devedup/NoThrillsImageLoading)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/NoThrillsImageLoading.svg)](https://cocoapods.org/pods/NoThrillsImageLoading)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/NoThrillsImageLoading.svg?style=flat)](http://cocoadocs.org/docsets/NoThrillsImageLoading)

## Goals

I wanted an image loading library that did cached image loading, with cancelable requests and nothing more. This is what I achieved with 'No Thrills Image Loading'. 

If you would rather have some thrills, such as filters, transitions, scaling, rounding, response serializers, etc etc ... then take a look at [Alamofire Image](https://github.com/Alamofire/AlamofireImage). 

## Features

* Simple code to understand using familiar Cocoa classes.
* Returns NSOperation from loads, which allows you to cancel requests. 
* Image loads are cached in memory using NSCache and on disk in Caches directory - switch out the cache if you want. 
* UImageView extension for most common use - is this a thrill? 
* Unit Tested
* Extend if you need more features (thrills) - you are a developer right? 

##Usage

#### Load an image into your UIImageView

```swift

imageView.loadFrom(imageURL)

```


