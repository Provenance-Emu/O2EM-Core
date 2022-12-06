#import "OdysseyGameCore.h"
//#include "crc32.h"
//#include "audio.h"
//#include "vmachine.h"
//#include "config.h"
//#include "vdc.h"
//#include "cpu.h"
//#include "debug.h"
//#include "keyboard.h"
//#include "voice.h"
//#include "vpp.h"

#include "wrapalleg.h"

#include "score.h"

#include "libretro.h"

int joystick_data[2][5]={{0,0,0,0,0},{0,0,0,0,0}};

@implementation OdysseyGameCore (Controls)

#pragma mark - Input

- (void)keyDown:(unsigned short)keyCode {
    NSNumber *virtualCode = [virtualPhysicalKeyMap objectForKey:@(keyCode)];

    if(virtualCode)
        key[[virtualCode intValue]] = 1;
}

- (void)keyUp:(unsigned short)keyCode {
    NSNumber *virtualCode = [virtualPhysicalKeyMap objectForKey:@(keyCode)];

    if(virtualCode)
        key[[virtualCode intValue]] = 0;
}

- (void)didPushOdyssey2Button:(PVOdyssey2Button)button forPlayer:(NSInteger)player {
//    player--;
    if (button == PVOdyssey2ButtonUp)
        joystick_data[player][0] = 1;
    else if (button == PVOdyssey2ButtonDown)
        joystick_data[player][1] = 1;
    else if (button == PVOdyssey2ButtonLeft)
        joystick_data[player][2] = 1;
    else if (button == PVOdyssey2ButtonRight)
        joystick_data[player][3] = 1;
    else if (button == PVOdyssey2ButtonAction)
        joystick_data[player][4] = 1;
}

- (void)didReleaseOdyssey2Button:(PVOdyssey2Button)button forPlayer:(NSInteger)player {
//    player--;
    if (button == PVOdyssey2ButtonUp)
        joystick_data[player][0] = 0;
    else if (button == PVOdyssey2ButtonDown)
        joystick_data[player][1] = 0;
    else if (button == PVOdyssey2ButtonLeft)
        joystick_data[player][2] = 0;
    else if (button == PVOdyssey2ButtonRight)
        joystick_data[player][3] = 0;
    else if (button == PVOdyssey2ButtonAction)
        joystick_data[player][4] = 0;
}

@end
