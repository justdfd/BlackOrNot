//
//  GLKView.swift
//

import CoreImage
import GLKit

public class ImageView: GLKView {
    
    var renderContext: CIContext
    var myClearColor:UIColor!
    var rgb:(Int?,Int?,Int?)!
    
    public var image: CIImage! {
        didSet {
            setNeedsDisplay()
        }
    }
    public var clearColor: UIColor! {
        didSet {
            myClearColor = clearColor
        }
    }
    public var originalSize = CGSize.zero
    public var filter:CIFilter!
    public var uiImage:UIImage? {
        get {
            let scaleFactor = originalSize.height / self.image.extent.height
            let transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            let output = self.image.transformed(by: transform)
            let final = renderContext.createCGImage(output, from: CGRect(x: 0, y: 0, width: originalSize.width, height: originalSize.height))
            return UIImage(cgImage: final!)
        }
    }
    
    public init() {
        let eaglContext = EAGLContext(api: .openGLES2)
        renderContext = CIContext(eaglContext: eaglContext!)
        super.init(frame: CGRect.zero)
        context = eaglContext!
    }
    
    override public init(frame: CGRect, context: EAGLContext) {
        renderContext = CIContext(eaglContext: context)
        super.init(frame: frame, context: context)
        enableSetNeedsDisplay = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        let eaglContext = EAGLContext(api: .openGLES2)
        renderContext = CIContext(eaglContext: eaglContext!)
        super.init(coder: aDecoder)
        context = eaglContext!
    }
    
    override public func draw(_ rect: CGRect) {
        if let image = image {
            let imageSize = image.extent.size
            var drawFrame = CGRect(x: 0, y: 0, width: CGFloat(drawableWidth), height: CGFloat(drawableHeight))
            let imageAR = imageSize.width / imageSize.height
            let viewAR = drawFrame.width / drawFrame.height
            if imageAR > viewAR {
                drawFrame.origin.y += (drawFrame.height - drawFrame.width / imageAR) / 2.0
                drawFrame.size.height = drawFrame.width / imageAR
            } else {
                drawFrame.origin.x += (drawFrame.width - drawFrame.height * imageAR) / 2.0
                drawFrame.size.width = drawFrame.height * imageAR
            }
            rgb = (0,0,0)
            rgb = myClearColor.rgb()
            //glClearColor(17.0/256.0, 42.0/256.0, 15.0/256.0, 1.0);
            //glClearColor(47.0/256.0, 47.0/256.0, 47.0/256.0, 0.0);
            glClearColor(Float(rgb.0!)/256.0, Float(rgb.1!)/256.0, Float(rgb.2!)/256.0, 0.0);
            glClear(0x00004000)
            // set the blend mode to "source over" so that CI will use that
            glEnable(0x0BE2);
            glBlendFunc(1, 0x0303);
            renderContext.draw(image, in: drawFrame, from: image.extent)
        }
    }
    
}
extension ImageView {
    public var scaleFactor:CGFloat {
        guard let image = self.image, self.frame != CGRect.zero  else {
            return 0.0
        }
        
        let frame = self.frame
        let extent = image.extent
        let heightFactor = frame.height/extent.height
        let widthFactor = frame.width/extent.width
        
        if extent.height > frame.height || extent.width > frame.width {
            if heightFactor < 1 && widthFactor < 1 {
                if heightFactor > widthFactor {
                    return widthFactor
                } else {
                    return heightFactor
                }
            } else if extent.height > frame.height {
                return heightFactor
            } else {
                return widthFactor
            }
        } else if extent.height < frame.height && extent.width < frame.width {
            if heightFactor < widthFactor {
                return heightFactor
            } else {
                return widthFactor
            }
        } else {
            return 1
        }
    }
    
    public var imageSize:CGSize {
        if self.image == nil {
            return CGSize.zero
        } else {
            return CGSize(width: (self.image?.extent.width)!, height: (self.image?.extent.height)!)
        }
    }
    
    public var scaledSize:CGSize {
        guard let image = self.image, self.frame != CGRect.zero  else {
            return CGSize.zero
        }
        let factor = self.scaleFactor
        return CGSize(width: image.extent.width * factor, height: image.extent.height * factor)
    }
}
extension UIColor {
    public func rgb() -> (Int?, Int?, Int?) {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            return (iRed, iGreen, iBlue)
        } else {
            // Could not extract RGBA components:
            return (nil,nil,nil)
        }
    }
    public func rgbFloat() -> (Float?, Float?, Float?) {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            return (Float(fRed), Float(fGreen), Float(fBlue))
        } else {
            // Could not extract RGBA components:
            return (nil,nil,nil)
        }
    }
}
