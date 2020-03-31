//
//  RNSharedElementStyle.m
//  react-native-shared-element
//

#import "RNSharedElementStyle.h"
#import <React/RCTView.h>

@implementation RNSharedElementStyle

- (instancetype)init
{
  if ((self = [super init])) {
    _cornerRadii = [RNSharedElementCornerRadii new];
  }
  return self;
}

- (instancetype)initWithView:(UIView*) view
{
  if ((self = [super init])) {
    _view = view;
    _size = view.bounds.size;
    _transform = [RNSharedElementStyle getAbsoluteViewTransform:view];
    
    // Set base props from style
    CALayer* layer = view.layer;
    _opacity = layer.opacity;
    _borderWidth = layer.borderWidth;
    _borderColor = layer.borderColor ? [UIColor colorWithCGColor:layer.borderColor] : [UIColor clearColor];
    _backgroundColor = layer.backgroundColor ? [UIColor colorWithCGColor:layer.backgroundColor] : [UIColor clearColor];
    _shadowColor = layer.shadowColor ? [UIColor colorWithCGColor:layer.shadowColor] : [UIColor clearColor];
    _shadowOffset = layer.shadowOffset;
    _shadowRadius = layer.shadowRadius;
    _shadowOpacity = layer.shadowOpacity;
    
    // On RN60 and beyond, certain styles are not immediately applied to the view/layer
    // when a borderWidth is set on the view. Therefore, as a fail-safe we also try to
    // get the props from the RCTView directly, when possible.
    if ([view isKindOfClass:[RCTView class]]) {
      RCTView* rctView = (RCTView*) view;
      _cornerRadii = [RNSharedElementStyle cornerRadiiFromRCTView: rctView];
      _borderColor = rctView.borderColor ? [UIColor colorWithCGColor:rctView.borderColor] : [UIColor clearColor];
      _borderWidth = rctView.borderWidth >= 0.0f ? rctView.borderWidth : 0.0f;
      _backgroundColor = rctView.backgroundColor ? rctView.backgroundColor : [UIColor clearColor];
    } else {
      _cornerRadii = [RNSharedElementCornerRadii new];
      [_cornerRadii setRadius:layer.cornerRadius corner:RNSharedElementCornerAll];
    }
  }
  
  return self;
}

+ (NSString*) stringFromTransform:(CATransform3D) transform {
  return [NSString stringWithFormat:@"x=%f, y=%f, z=%f",
          transform.m41, transform.m42, transform.m43];
}

+ (CATransform3D) getAbsoluteViewTransform:(UIView*) view
{
  CATransform3D transform = view.layer.transform;
  view = view.superview;
  while (view != nil) {
    CATransform3D t2 = view.layer.transform;
    // Other transform props are not needed for now, maybe support them later
    /*transform.m11 *= t2.m11;
     transform.m12 *= t2.m12;
     transform.m13 *= t2.m13;
     transform.m14 *= t2.m14;
     transform.m21 *= t2.m21;
     transform.m22 *= t2.m22;
     transform.m23 *= t2.m23;
     transform.m24 *= t2.m24;
     transform.m31 *= t2.m31;
     transform.m32 *= t2.m32;
     transform.m33 *= t2.m33;
     transform.m34 *= t2.m34;*/
    transform.m41 += t2.m41; // translateX
    transform.m42 += t2.m42; // translateY
    transform.m43 += t2.m43; // translateZ
    //transform.m44 *= t2.m44;
    view = view.superview;
  }
  return transform;
}

+ (UIColor*) getInterpolatedColor:(UIColor*)color1 color2:(UIColor*)color2 position:(CGFloat)position
{
  CGFloat red1, green1, blue1, alpha1;
  CGFloat red2, green2, blue2, alpha2;
  [color1 getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
  [color2 getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
  CGFloat alpha = alpha1 + ((alpha2 - alpha1) * position);
  CGFloat red = red1 + ((red2 - red1) * position);
  CGFloat green = green1 + ((green2 - green1) * position);
  CGFloat blue = blue1 + ((blue2 - blue1) * position);
  if ((alpha1 == 0.0f) && (alpha2 != 0.0f)) {
    red = red2;
    green = green2;
    blue = blue2;
  } else if ((alpha2 == 0.0f) && (alpha1 != 0.0f)) {
    red = red1;
    green = green1;
    blue = blue1;
  }
  return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (RNSharedElementStyle*) getInterpolatedStyle:(RNSharedElementStyle*)style1 style2:(RNSharedElementStyle*)style2 position:(CGFloat) position
{
  RNSharedElementStyle* style = [[RNSharedElementStyle alloc]init];
  style.opacity = style1.opacity + ((style2.opacity - style1.opacity) * position);
  
  CGRect radiiRect = CGRectMake(0, 0, 1000000, 1000000);
  RCTCornerRadii radii1 = [style1.cornerRadii radiiForBounds:radiiRect];
  RCTCornerRadii radii2 = [style2.cornerRadii radiiForBounds:radiiRect];
  [style.cornerRadii setRadius:radii1.topLeft + ((radii2.topLeft - radii1.topLeft) * position) corner:RNSharedElementCornerTopLeft];
  [style.cornerRadii setRadius:radii1.topRight + ((radii2.topRight - radii1.topRight) * position) corner:RNSharedElementCornerTopRight];
  [style.cornerRadii setRadius:radii1.bottomLeft + ((radii2.bottomLeft - radii1.bottomLeft) * position) corner:RNSharedElementCornerBottomLeft];
  [style.cornerRadii setRadius:radii1.bottomRight + ((radii2.bottomRight - radii1.bottomRight) * position) corner:RNSharedElementCornerBottomRight];
  
  style.borderWidth = style1.borderWidth + ((style2.borderWidth - style1.borderWidth) * position);
  style.borderColor = [RNSharedElementStyle getInterpolatedColor:style1.borderColor color2:style2.borderColor position:position];
  style.backgroundColor = [RNSharedElementStyle getInterpolatedColor:style1.backgroundColor color2:style2.backgroundColor position:position];
  style.shadowOpacity = style1.shadowOpacity + ((style2.shadowOpacity - style1.shadowOpacity) * position);
  style.shadowRadius = style1.shadowRadius + ((style2.shadowRadius - style1.shadowRadius) * position);
  style.shadowOffset = CGSizeMake(
                                  style1.shadowOffset.width + ((style2.shadowOffset.width - style1.shadowOffset.width) * position),
                                  style1.shadowOffset.height + ((style2.shadowOffset.height - style1.shadowOffset.height) * position)
                                  );
  style.shadowColor = [RNSharedElementStyle getInterpolatedColor:style1.shadowColor color2:style2.shadowColor position:position];
  return style;
}

+ (RNSharedElementCornerRadii *)cornerRadiiFromRCTView:(RCTView *)rctView
{
  RNSharedElementCornerRadii *cornerRadii = [RNSharedElementCornerRadii new];
  [cornerRadii setRadius:[rctView borderRadius] corner:RNSharedElementCornerAll];
  [cornerRadii setRadius:[rctView borderTopLeftRadius] corner:RNSharedElementCornerTopLeft];
  [cornerRadii setRadius:[rctView borderTopRightRadius] corner:RNSharedElementCornerTopRight];
  [cornerRadii setRadius:[rctView borderTopStartRadius] corner:RNSharedElementCornerTopStart];
  [cornerRadii setRadius:[rctView borderTopEndRadius] corner:RNSharedElementCornerTopEnd];
  [cornerRadii setRadius:[rctView borderBottomLeftRadius] corner:RNSharedElementCornerBottomLeft];
  [cornerRadii setRadius:[rctView borderBottomRightRadius] corner:RNSharedElementCornerBottomRight];
  [cornerRadii setRadius:[rctView borderBottomStartRadius] corner:RNSharedElementCornerBottomStart];
  [cornerRadii setRadius:[rctView borderBottomEndRadius] corner:RNSharedElementCornerBottomEnd];
  [cornerRadii setLayoutDirection:[rctView reactLayoutDirection]];
  return cornerRadii;
}

@end
