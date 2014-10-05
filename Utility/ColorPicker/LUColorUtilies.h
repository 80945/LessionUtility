//
//  LUColorUtilies.h
//  LessionUtility
//
//  Created by 256 on 6/1/14.
//  Copyright (c) 2014 256. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIColor+HSB_RGB.h"


#if LU_DEBUG
#define LULog NSLog
#else
#define LULog(...)
#endif

#if LU_DEBUG
void LUBeginTiming();
#else
#define LUBeginTiming(...)
#endif

#if LU_DEBUG
void LULogTiming(NSString *message); // intermediate message to log before end timing is called
#else
#define LULogTiming(...)
#endif

#if LU_DEBUG
void LUEndTiming(NSString *message);
#else
#define LUEndTiming(...)
#endif

float LUSineCurve(float input);

void LUDrawCheckersInRect(CGContextRef ctx, CGRect dest, int size);
void LUDrawTransparencyDiamondInRect(CGContextRef ctx, CGRect dest);

void LUContextDrawImageToFill(CGContextRef ctx, CGRect bounds, CGImageRef imageRef);

CGSize LUSizeOfRectWithAngle(CGRect rect, float angle, CGPoint *upperLeft, CGPoint *upperRight);

CGPoint LUNormalizePoint(CGPoint vector);

float OSVersion();

CGRect LUGrowRectToPoint(CGRect rect, CGPoint pt);

NSData * LUSHA1DigestForData(NSData *data);

CGPoint LUSharpPointInContext(CGPoint pt, CGContextRef ctx);

CGPoint LUConstrainPoint(CGPoint pt);

CGRect LURectFromPoint(CGPoint a, float width, float height);

CGPathRef LUConvertPathQuadraticToCubic(CGPathRef pathRef);

BOOL LUCollinear(CGPoint a, CGPoint b, CGPoint c);

BOOL LULineInRect(CGPoint a, CGPoint b, CGRect test);

CGPathRef LUTransformCGPathRef(CGPathRef pathRef, CGAffineTransform transform);

BOOL LULineSegmentsIntersectWithValues(CGPoint A, CGPoint B, CGPoint C, CGPoint D, float *r, float *s);
BOOL LULineSegmentsIntersect(CGPoint A, CGPoint B, CGPoint C, CGPoint D);

CGRect LUShrinkRect(CGRect rect, float percentage);

CGAffineTransform LUTransformForOrientation(UIInterfaceOrientation orientation);

float LURandomFloat();
int LURandomIntInRange(int min, int max);
float LURandomFloatInRange(float min, float max);

CGRect LUUnionRect(CGRect a, CGRect b);

void LUCheckGLError_(const char *file, int line);
#if LU_DEBUG
#define LUCheckGLError() LUCheckGLError_(__FILE__, __LINE__);
#else
#define LUCheckGLError()
#endif

NSString * generateUUID();

BOOL LUDeviceIsPhone();
BOOL LUDeviceIs4InchPhone();
BOOL LUUseModernAppearance();

BOOL LUCanUseScissorTest();

size_t LUGetTotalMemory();
BOOL LUCanUseHDTextures();

/******************************
 * LUQuad
 *****************************/

typedef struct {
    CGPoint     corners[4];
} LUQuad;

LUQuad LUQuadNull();
LUQuad LUQuadMake(CGPoint a, CGPoint b, CGPoint c, CGPoint d);
LUQuad LUQuadWithRect(CGRect rect, CGAffineTransform transform);
BOOL LUQuadEqualToQuad(LUQuad a, LUQuad b);
BOOL LUQuadIntersectsQuad(LUQuad a, LUQuad b);
CGPathRef LUQuadCreatePathRef(LUQuad q);
NSString * NSStringFromLUQuad(LUQuad quad);

/******************************
 * static inline functions
 *****************************/

static inline float LUIntDistance(int x1, int y1, int x2, int y2) {
    int xd = (x1-x2), yd = (y1-y2);
    return sqrt(xd * xd + yd * yd);
}

static inline CGPoint LUAddPoints(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint LUSubtractPoints(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGSize LUAddSizes(CGSize a, CGSize b) {
    return CGSizeMake(a.width + b.width, a.height + b.height);
}


static inline float LUDistance(CGPoint a, CGPoint b) {
    float xd = (a.x - b.x);
    float yd = (a.y - b.y);
    
    return sqrt(xd * xd + yd * yd);
}

static inline float LUClamp(float min, float max, float value) {
    return (value < min) ? min : (value > max) ? max : value;
}

static inline CGPoint LUCenterOfRect(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

static inline CGRect LUMultiplyRectScalar(CGRect r, float s) {
    return CGRectMake(r.origin.x * s, r.origin.y * s, r.size.width * s, r.size.height * s);
}

static inline CGSize LUMultiplySizeScalar(CGSize size, float s) {
    return CGSizeMake(size.width * s, size.height * s);
}

static inline CGPoint LUMultiplyPointScalar(CGPoint p, float s) {
    return CGPointMake(p.x * s, p.y * s);
}

static inline CGRect LURectWithPoints(CGPoint a, CGPoint b) {
    float minx = MIN(a.x, b.x);
    float maxx = MAX(a.x, b.x);
    float miny = MIN(a.y, b.y);
    float maxy = MAX(a.y, b.y);
    
    return CGRectMake(minx, miny, maxx - minx, maxy - miny);
}

static inline CGRect LURectWithPointsConstrained(CGPoint a, CGPoint b, BOOL constrained) {
    float minx = MIN(a.x, b.x);
    float maxx = MAX(a.x, b.x);
    float miny = MIN(a.y, b.y);
    float maxy = MAX(a.y, b.y);
    float dimx = maxx - minx;
    float dimy = maxy - miny;
    
    if (constrained) {
        dimx = dimy = MAX(dimx, dimy);
    }
    
    return CGRectMake(minx, miny, dimx, dimy);
}

static inline CGRect LUFlipRectWithinRect(CGRect src, CGRect dst)
{
    src.origin.y = CGRectGetMaxY(dst) - CGRectGetMaxY(src);
    return src;
}

static inline CGPoint LUFloorPoint(CGPoint pt)
{
    return CGPointMake(floor(pt.x), floor(pt.y));
}

static inline CGPoint LURoundPoint(CGPoint pt)
{
    return CGPointMake(round(pt.x), round(pt.y));
}

static inline CGPoint LUAveragePoints(CGPoint a, CGPoint b)
{
    return LUMultiplyPointScalar(LUAddPoints(a, b), 0.5f);
}

static inline CGSize LURoundSize(CGSize size)
{
    return CGSizeMake(round(size.width), round(size.height));
}

static inline float LUMagnitude(CGPoint point)
{
    return LUDistance(point, CGPointZero);
}
