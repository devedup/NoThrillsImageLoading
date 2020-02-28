# No Thrills Image Loading - Swift 5

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


