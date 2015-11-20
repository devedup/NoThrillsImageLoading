# No Thrills Image Loading in Swift

i.e. It just does one job simply... loads an image from the disk cache or from the network and then caches to disk in the devices caches directory

####Master build status: 
![](https://travis-ci.org/devedup/NoThrillsImageLoading.svg?branch=master)

####Usage

```swift
let imageURL = NSURL(string:"http://www.mysite.com/image.png")!
let imageOp = ImageCenter.imageForURL(imageURL) { (image) -> Void in
    if let image = image {
				// do somethign with the image
		}
}
// imageOp?cancel() // if you want to cancel the load
```

