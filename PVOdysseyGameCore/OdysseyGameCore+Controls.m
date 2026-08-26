#import "OdysseyGameCore.h"

@import PVEmulatorCore;
@import PVCoreBridge;
@import PVCoreObjCBridge;
//#import "crc32.h"
//#import "audio.h"
//#import "vmachine.h"
//#import "config.h"
//#import "vdc.h"
//#import "cpu.h"
//#import "debug.h"
//#import "keyboard.h"
//#import "voice.h"
//#import "vpp.h"

#import "wrapalleg.h"

#import "score.h"

#import "libretro.h"

int joystick_data[2][5]={{0,0,0,0,0},{0,0,0,0,0}};

@implementation OdysseyGameCoreBridge (Controls)

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
    else if (button == PVOdyssey2ButtonKey0)
        key[RETROK_0] = 1;
    else if (button == PVOdyssey2ButtonKey1)
        key[RETROK_1] = 1;
    else if (button == PVOdyssey2ButtonKey2)
        key[RETROK_2] = 1;
    else if (button == PVOdyssey2ButtonKey3)
        key[RETROK_3] = 1;
    else if (button == PVOdyssey2ButtonKey4)
        key[RETROK_4] = 1;
    else if (button == PVOdyssey2ButtonKey5)
        key[RETROK_5] = 1;
    else if (button == PVOdyssey2ButtonKey6)
        key[RETROK_6] = 1;
    else if (button == PVOdyssey2ButtonKey7)
        key[RETROK_7] = 1;
    else if (button == PVOdyssey2ButtonKey8)
        key[RETROK_8] = 1;
    else if (button == PVOdyssey2ButtonKey9)
        key[RETROK_9] = 1;
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
    else if (button == PVOdyssey2ButtonKey0)
        key[RETROK_0] = 0;
    else if (button == PVOdyssey2ButtonKey1)
        key[RETROK_1] = 0;
    else if (button == PVOdyssey2ButtonKey2)
        key[RETROK_2] = 0;
    else if (button == PVOdyssey2ButtonKey3)
        key[RETROK_3] = 0;
    else if (button == PVOdyssey2ButtonKey4)
        key[RETROK_4] = 0;
    else if (button == PVOdyssey2ButtonKey5)
        key[RETROK_5] = 0;
    else if (button == PVOdyssey2ButtonKey6)
        key[RETROK_6] = 0;
    else if (button == PVOdyssey2ButtonKey7)
        key[RETROK_7] = 0;
    else if (button == PVOdyssey2ButtonKey8)
        key[RETROK_8] = 0;
    else if (button == PVOdyssey2ButtonKey9)
        key[RETROK_9] = 0;
}

@end
