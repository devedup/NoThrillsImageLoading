# No Thrills Image Loading in Swift

Do you have a URL? Do you want an Image? I think I can help you. 

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

