//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesBubbleImageFactory.h"

#import "UIImage+JSQMessages.h"
#import "UIColor+JSQMessages.h"


@interface JSQMessagesBubbleImageFactory ()

@property (strong, nonatomic, readonly) UIImage *bubbleImage;

@property (assign, nonatomic, readonly) UIEdgeInsets capInsets;

@property (assign, nonatomic, readonly) BOOL isRightToLeftLanguage;

@end


@implementation JSQMessagesBubbleImageFactory

#pragma mark - Initialization

- (instancetype)initWithBubbleImage:(UIImage *)bubbleImage
                          capInsets:(UIEdgeInsets)capInsets
                    layoutDirection:(UIUserInterfaceLayoutDirection)layoutDirection
{
    NSParameterAssert(bubbleImage != nil);

    self = [super init];
    if (self) {
        _bubbleImage = bubbleImage;
        _capInsets = capInsets;
        _layoutDirection = layoutDirection;

        if (UIEdgeInsetsEqualToEdgeInsets(capInsets, UIEdgeInsetsZero)) {
            _capInsets = [self jsq_centerPointEdgeInsetsForImageSize:bubbleImage.size];
        }
    }
    return self;
}

- (instancetype)init
{
    return [self initWithBubbleImage:[UIImage jsq_bubbleCompactImage]
                           capInsets:UIEdgeInsetsZero
                     layoutDirection:[UIApplication sharedApplication].userInterfaceLayoutDirection];
}

#pragma mark - Public

- (JSQMessagesBubbleImage *)outgoingMessagesBubbleImageWithColor:(UIColor *)color
{
    return [self jsq_messagesBubbleImageWithColor:color borderColor: color flippedForIncoming:NO];

//    return [self jsq_messagesBubbleImageWithColor:color flippedForIncoming:NO ^ self.isRightToLeftLanguage];
}

- (JSQMessagesBubbleImage *)incomingMessagesBubbleImageWithColor:(UIColor *)color
{
    return [self jsq_messagesBubbleImageWithColor:color borderColor: color flippedForIncoming:YES];

//    return [self jsq_messagesBubbleImageWithColor:color flippedForIncoming:YES ^ self.isRightToLeftLanguage];
}


- (JSQMessagesBubbleImage *)jsq_messagesBubbleImageWithColor:(UIColor *)color borderColor:(UIColor *)borderColor flippedForIncoming:(BOOL)flippedForIncoming
{
    NSParameterAssert(color != nil);
    
    UIImage *image = [UIImage jsq_bubbleRegularImage];
    UIImage *strokedImage = [UIImage jsq_bubbleRegularStrokedImage];
    UIImage *coloredImage;
    UIImage *coloredStrokedImage;
    
    coloredImage = [image jsq_imageMaskedWithColor: [UIColor colorWithRed: 208.f/255.f green:208.f/255.f blue:208.f/255.f alpha:1.f]];
    coloredStrokedImage = [strokedImage jsq_imageMaskedWithColor:borderColor];
    
    UIImage *normalBubble = [self addImage:coloredImage withImage:coloredStrokedImage];
    
    color = [color jsq_colorByDarkeningColorWithValue:0.01f];
    
    coloredImage = [image jsq_imageMaskedWithColor:color];
    coloredStrokedImage = [strokedImage jsq_imageMaskedWithColor:borderColor];
    
    UIImage *highlightedBubble = [self addImage:coloredImage withImage:coloredStrokedImage];
    
    if (flippedForIncoming) {
        normalBubble = [self jsq_horizontallyFlippedImageFromImage:normalBubble];
        highlightedBubble = [self jsq_horizontallyFlippedImageFromImage:highlightedBubble];
    }
    
    normalBubble = [self jsq_stretchableImageFromImage:normalBubble withCapInsets:self.capInsets];
    highlightedBubble = [self jsq_stretchableImageFromImage:highlightedBubble withCapInsets:self.capInsets];
    
    return [[JSQMessagesBubbleImage alloc] initWithMessageBubbleImage:normalBubble highlightedImage:highlightedBubble];
}

- (UIImage *)addImage:(UIImage *)image1 withImage:(UIImage *)image2
{
    UIImage *result;
    
    UIGraphicsBeginImageContext(image1.size);
    {
        [image1 drawAtPoint:CGPointZero];
        [image2 drawAtPoint:CGPointMake(0, -1)];
        result = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return result;
}

#pragma mark - Private

- (BOOL)isRightToLeftLanguage
{
    return (self.layoutDirection == UIUserInterfaceLayoutDirectionRightToLeft);
}

- (UIEdgeInsets)jsq_centerPointEdgeInsetsForImageSize:(CGSize)bubbleImageSize
{
    // make image stretchable from center point
    CGPoint center = CGPointMake(bubbleImageSize.width / 2.0f, bubbleImageSize.height / 2.0f);
    return UIEdgeInsetsMake(center.y, center.x, center.y, center.x);
}

- (JSQMessagesBubbleImage *)jsq_messagesBubbleImageWithColor:(UIColor *)color flippedForIncoming:(BOOL)flippedForIncoming
{
    NSParameterAssert(color != nil);

    UIImage *normalBubble = [self.bubbleImage jsq_imageMaskedWithColor:color];
    UIImage *highlightedBubble = [self.bubbleImage jsq_imageMaskedWithColor:[color jsq_colorByDarkeningColorWithValue:0.12f]];

    if (flippedForIncoming) {
        normalBubble = [self jsq_horizontallyFlippedImageFromImage:normalBubble];
        highlightedBubble = [self jsq_horizontallyFlippedImageFromImage:highlightedBubble];
    }

    normalBubble = [self jsq_stretchableImageFromImage:normalBubble withCapInsets:self.capInsets];
    highlightedBubble = [self jsq_stretchableImageFromImage:highlightedBubble withCapInsets:self.capInsets];

    return [[JSQMessagesBubbleImage alloc] initWithMessageBubbleImage:normalBubble highlightedImage:highlightedBubble];
}

- (UIImage *)jsq_horizontallyFlippedImageFromImage:(UIImage *)image
{
    return [UIImage imageWithCGImage:image.CGImage
                               scale:image.scale
                         orientation:UIImageOrientationUpMirrored];
}

- (UIImage *)jsq_stretchableImageFromImage:(UIImage *)image withCapInsets:(UIEdgeInsets)capInsets
{
    return [image resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
}

@end
