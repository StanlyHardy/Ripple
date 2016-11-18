//The MIT License (MIT)
//
//Copyright (c) 2016 Stanly Moses <stanlyhardy@yahoo.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

#import "Ripple.h"
#define initialSize 20
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

@implementation Ripple

static Ripple *sharedAwardCenter = nil;

+ (Ripple *)sharedCenter {
    if (sharedAwardCenter == nil) {
        sharedAwardCenter = [[super allocWithZone:NULL] init];
    }
    return sharedAwardCenter;
}


typedef void (^animationCompletionBlock)(void);

- (UIColor *)randomColor
{
    if (!_colors) {
        _colors = @[
                    UIColorFromRGB(0xff7f7f),
                    UIColorFromRGB(0xff7fbf),
                    UIColorFromRGB(0xff7fff),
                    UIColorFromRGB(0xbf7fff),
                    UIColorFromRGB(0x7f7fff),
                    UIColorFromRGB(0x7fbfff),
                    UIColorFromRGB(0x7fffff),
                    UIColorFromRGB(0x7fffbf),
                    UIColorFromRGB(0x7fff7f),
                    UIColorFromRGB(0xbfff7f),
                    UIColorFromRGB(0xffff7f),
                    UIColorFromRGB(0xffbf7f)
                    ];
    }
    
    NSInteger count = _colors.count;
    NSInteger r = arc4random() % count;
    return _colors[r];
}

-(void) generateRipples: (UIView* ) view  withTouch: (UITouch *)touch{
    
    if (!view) {
        return;
    }
    [view setClipsToBounds:YES];
    rippleLayer = [CALayer layer];;
    rippleLayer.backgroundColor = view.tintColor?[[view.tintColor colorWithAlphaComponent:0.3] CGColor]:[UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
    rippleLayer.frame = CGRectMake(0, 0, initialSize, initialSize);
    rippleLayer.cornerRadius = initialSize/2;
    rippleLayer.masksToBounds =  YES;
    rippleLayer.position = [touch locationInView:view];
    [view.layer addSublayer:rippleLayer];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [animation setToValue:[NSNumber numberWithFloat:(2.5*MAX(view.frame.size.height, view.frame.size.width))/initialSize]];
    [animation setDuration:0.6f];
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode:kCAFillModeForwards];
    
    CAKeyframeAnimation *fade = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    fade.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0],[NSNumber numberWithFloat:1.0],[NSNumber numberWithFloat:1.0],[NSNumber numberWithFloat:0.5],[NSNumber numberWithFloat:0.0], nil];
    fade.duration = 0.5;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.duration  = 0.5f;
    animGroup.delegate=self;
    animGroup.animations = [NSArray arrayWithObjects:animation,fade, nil];
    [animGroup setValue:rippleLayer forKey:@"animationLayer"];
    [rippleLayer addAnimation:animGroup forKey:@"scale"];
    
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    CALayer *layer = [anim valueForKey:@"animationLayer"];
    if(layer){
        [layer removeAnimationForKey:@"scale"];
        [layer removeFromSuperlayer];
        layer = nil;
        anim = nil;
    }
}

- (void)rippleWithRandomColor:(UIView *)view inRootView:(UIView *)parentView{
    if (!view) {
        return;
    }
    
    UIView* ripple = [[UIView alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
    ripple.backgroundColor = [[self randomColor ] colorWithAlphaComponent:0.0f];
    [parentView addSubview:ripple];
    
    [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        CGRect newFrame = view.frame;
        [ripple setFrame:newFrame];
        ripple.transform = CGAffineTransformMakeScale(0.1, 0.1);
        ripple.alpha = 0.0f;
        ripple.backgroundColor = [self randomColor];
    } completion:^(BOOL finished) {
        ripple.transform = CGAffineTransformIdentity;
        [ripple removeFromSuperview];
    }];
}

- (void)generateColourfulRipples:(UIView *)view inRootView: (UIView*) parentView center:(CGPoint)center  colorFrom:(UIColor *)colorFrom colorTo:(UIColor *)colorTo{
    if (!view) {
        return;
    }
    UIView* ripple = [[UIView alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
    ripple.layer.cornerRadius = view.frame.size.height * 0.5f;
    ripple.backgroundColor = [colorFrom colorWithAlphaComponent:0.0f];
    [parentView addSubview:ripple];
    [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        ripple.transform = CGAffineTransformMakeScale(0.1, 0.1);
        ripple.alpha = 0.0f;
        ripple.backgroundColor = colorTo;
    } completion:^(BOOL finished) {
        [ripple removeFromSuperview];
    }];
}
@end
