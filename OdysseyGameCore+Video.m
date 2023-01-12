#import "OdysseyGameCore.h"

#if !TARGET_OS_MACCATALYST && !TARGET_OS_OSX
#import <OpenGLES/gltypes.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <OpenGLES/EAGL.h>
#else
@import OpenGL;
@import GLUT;
#endif

#import "vmachine.h"
#import "wrapalleg.h"

extern uint16_t *mbmp;

@implementation OdysseyGameCore (Video)

#pragma mark Video

/*
 The O2EM core's max width is 340
 The O2EM core's max height is 250
 The O2EM core's core provided aspect ratio is 4/3
 */

- (CGSize)aspectSize { return CGSizeMake(4, 3); }
- (CGRect)screenRect { return CGRectMake(0, 0, EMUWIDTH, EMUHEIGHT); }
- (CGSize)bufferSize { return CGSizeMake(TEX_WIDTH, TEX_HEIGHT); }

- (GLenum)pixelFormat { return GL_RGB; }
- (GLenum)internalPixelFormat { return GL_RGB; }
- (GLenum)pixelType { return GL_UNSIGNED_SHORT_5_6_5; }
- (NSTimeInterval)frameInterval { return evblclk == EVBLCLK_NTSC ? 60 : 50; }

- (const void *)videoBuffer { return [self getVideoBufferWithHint:nil]; }
- (BOOL)isDoubleBuffered { return false; }

- (const void *)getVideoBufferWithHint:(void *)hint {
    if(!hint) {
        if(!mbmp) {
            hint = mbmp = (uint16_t*)malloc(TEX_WIDTH * TEX_HEIGHT * sizeof(uint16_t));
        }
    } else {
        mbmp = hint;
    }

    return mbmp;
}

@end
