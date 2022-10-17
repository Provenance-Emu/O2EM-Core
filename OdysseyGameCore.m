/*
 Copyright (c) 2022, Provenance EMU Team
 */

#import "OdysseyGameCore.h"
//#import "OEOdyssey2SystemResponderClient.h"
@import PVSupport.Swift;
//b#import <PVSupport/PVSupport-Swift.h>

#if !TARGET_OS_MACCATALYST
#import <OpenGLES/gltypes.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <OpenGLES/EAGL.h>
#else
@import OpenGL;
@import GLUT;
#endif

#import <UIKit/UIKeyConstants.h>

#include "crc32.h"
#include "audio.h"
#include "vmachine.h"
#include "config.h"
#include "vdc.h"
#include "cpu.h"
#include "debug.h"
#include "keyboard.h"
#include "voice.h"
#include "vpp.h"

#include "wrapalleg.h"

#include "score.h"

#include "libretro.h"

@interface OdysseyGameCore () <PVOdyssey2SystemResponderClient>
{
}
@end

//uint16_t mbmp[EMUWIDTH * EMUHEIGHT];
//unsigned short int mbmp[TEX_WIDTH * TEX_HEIGHT];
uint16_t *mbmp;
short signed int SNDBUF[1024*2];
uint8_t soundBuffer[1056];
int SND;
int RLOOP=0;

void update_joy(void){

}

int contax, o2flag, g74flag, c52flag, jopflag, helpflag;

unsigned long crcx = ~0;

static char bios[MAXC], scshot[MAXC], xrom[MAXC], romdir[MAXC], xbios[MAXC],
biosdir[MAXC], arkivo[MAXC][MAXC], biossux[MAXC], romssux[MAXC],
odyssey2[MAXC], g7400[MAXC], c52[MAXC], jopac[MAXC], file_l[MAXC], bios_l[MAXC],
file_v[MAXC],scorefile[MAXC], statefile[MAXC], path2[MAXC];

extern void retro_destroybmp(void);

static long filesize(FILE *stream){
    long curpos, length;
    curpos = ftell(stream);
    fseek(stream, 0L, SEEK_END);
    length = ftell(stream);
    fseek(stream, curpos, SEEK_SET);
    return length;
}

static int load_bios(const char *biosname){
	FILE *fn;
	static char s[MAXC+10];
	unsigned long crc;
	int i;
    
    if ((biosname[strlen(biosname)-1]=='/') ||
        (biosname[strlen(biosname)-1]=='\\') ||
        (biosname[strlen(biosname)-1]==':')) {
		strcpy(s,biosname);
		strcat(s,odyssey2);
		fn = fopen(s,"rb");
        
		if (!fn) {
			strcpy(s,biosname);
			strcat(s,odyssey2);
			fn = fopen(s,"rb");
        }
    } else {
        
    	strcpy(s,biosname);
		fn = fopen(biosname,"rb");
    }
	
    if (!fn) {
		fprintf(stderr,"Error loading bios ROM (%s)\n",s);
		return EXIT_FAILURE;
	}
 	if (fread(rom_table[0],1024,1,fn) != 1) {
 		fprintf(stderr,"Error loading bios ROM %s\n",odyssey2);
        return EXIT_FAILURE;
 	}
    
    strcpy(s,biosname);
    fn = fopen(biosname,"rb");
    if (!fn) {
		fprintf(stderr,"Error loading bios ROM (%s)\n",s);
        return EXIT_FAILURE;
	}
 	if (fread(rom_table[0],1024,1,fn) != 1) {
 		fprintf(stderr,"Error loading bios ROM %s\n",odyssey2);
        return EXIT_FAILURE;
 	}
    fclose(fn);
	for (i=1; i<8; i++) memcpy(rom_table[i],rom_table[0],1024);
	crc = crc32_buf(rom_table[0],1024);
	if (crc==0x8016A315) {
		printf("Odyssey2 bios ROM loaded\n");
		app_data.vpp = 0;
		app_data.bios = ROM_O2;
	} else if (crc==0xE20A9F41) {
		printf("Videopac+ G7400 bios ROM loaded\n");
		app_data.vpp = 1;
		app_data.bios = ROM_G7400;
	} else if (crc==0xA318E8D6) {
		if (!((!o2flag)&&(c52flag))) printf("C52 bios ROM loaded\n"); else printf("Ok\n");
		app_data.vpp = 0;
		app_data.bios = ROM_C52;
		
	} else if (crc==0x11647CA5) {
		if (g74flag) printf("Jopac bios ROM loaded\n"); else printf(" Ok\n");
		app_data.vpp = 1;
		app_data.bios = ROM_JOPAC;
	} else {
		printf("Bios ROM loaded (unknown version)\n");
		app_data.vpp = 0;
		app_data.bios = ROM_UNKNOWN;
	}
    return EXIT_SUCCESS;
}

static int load_cart(const char *file){
	FILE *fn;
	long l;
	int i, nb;
    
	app_data.crc = crc32_file(file);
	if (app_data.crc == 0xAFB23F89) app_data.exrom = 1;  /* Musician */
	if (app_data.crc == 0x3BFEF56B) app_data.exrom = 1;  /* Four in 1 Row! */
	if (app_data.crc == 0x9B5E9356) app_data.exrom = 1;  /* Four in 1 Row! (french) */
    
	if (((app_data.crc == 0x975AB8DA) || (app_data.crc == 0xE246A812)) && (!app_data.debug)) {
		fprintf(stderr,"Error: file %s is an incomplete ROM dump\n",file_v);
        return EXIT_FAILURE;
	}
	
    fn=fopen(file,"rb");
	if (!fn) {
		fprintf(stderr,"Error loading %s\n",file_v);
        return EXIT_FAILURE;
	}
	printf("Loading: \"%s\"  Size: ",file_v);
	l = filesize(fn);
	
    if ((l % 1024) != 0) {
		fprintf(stderr,"Error: file %s is an invalid ROM dump\n",file_v);
        return EXIT_FAILURE;
	}
    
    /* special MegaCART design by Soeren Gust */
	if ((l == 32768) || (l == 65536) || (l == 131072) || (l == 262144) || (l == 524288) || (l == 1048576)) {
		app_data.megaxrom = 1;
		app_data.bank = 1;
		megarom = malloc(1048576);
		if (megarom == NULL) {
			fprintf(stderr, "Out of memory loading %s\n", file);
            return EXIT_FAILURE;
        }
		if (fread(megarom, l, 1, fn) != 1) {
			fprintf(stderr,"Error loading %s\n",file);
            return EXIT_FAILURE;
		}
		
        /* mirror shorter files into full megabyte */
		if (l < 65536) memcpy(megarom+32768,megarom,32768);
		if (l < 131072) memcpy(megarom+65536,megarom,65536);
		if (l < 262144) memcpy(megarom+131072,megarom,131072);
		if (l < 524288) memcpy(megarom+262144,megarom,262144);
		if (l < 1048576) memcpy(megarom+524288,megarom,524288);
		/* start in bank 0xff */
		memcpy(&rom_table[0][1024], megarom + 4096*255 + 1024, 3072);
		printf("MegaCart %ldK", l / 1024);
		nb = 1;
	} else if (((l % 3072) == 0))
    {
		app_data.three_k = 1;
		nb = l/3072;
        
		for (i=nb-1; i>=0; i--) {
			if (fread(&rom_table[i][1024],3072,1,fn) != 1) {
				fprintf(stderr,"Error loading %s\n",file);
                return EXIT_FAILURE;
			}
		}
		printf("%dK",nb*3);
        
	} else {
        
		nb = l/2048;
        
		if ((nb == 2) && (app_data.exrom)) {
            
			if (fread(&extROM[0], 1024,1,fn) != 1) {
				fprintf(stderr,"Error loading %s\n",file);
                return EXIT_FAILURE;
			}
			if (fread(&rom_table[0][1024],3072,1,fn) != 1) {
				fprintf(stderr,"Error loading %s\n",file);
                return EXIT_FAILURE;
			}
			printf("3K EXROM");
            
		} else {
            
			for (i=nb-1; i>=0; i--) {
				if (fread(&rom_table[i][1024],2048,1,fn) != 1) {
					fprintf(stderr,"Error loading %s\n",file);
                    return EXIT_FAILURE;
				}
				memcpy(&rom_table[i][3072],&rom_table[i][2048],1024); /* simulate missing A10 */
			}
			printf("%dK",nb*2);
            
		}
	}
	fclose(fn);
	rom = rom_table[0];
	if (nb==1)
        app_data.bank = 1;
	else if (nb==2)
		app_data.bank = app_data.exrom ? 1 : 2;
	else if (nb==4)
		app_data.bank = 3;
	else
		app_data.bank = 4;
	
    if ((rom_table[nb-1][1024+12]=='O') && (rom_table[nb-1][1024+13]=='P') && (rom_table[nb-1][1024+14]=='N') && (rom_table[nb-1][1024+15]=='B')) app_data.openb=1;
	
    printf("  CRC: %08lX\n",app_data.crc);
    
    return EXIT_SUCCESS;
}

//int suck_bios()
//{
//    int i;
//    for (i=0; i<contax; ++i)
//    {
//        strcpy(biossux,biosdir);
//        strcat(biossux,arkivo[i]);
//        identify_bios(biossux);
//    }
//    return(0);
//}
/********************* Search ROM */
//int suck_roms()
//{
//    int i;
//    rom_f = 1;
//    for (i=0; i<contax; ++i)
//    {
//        strcpy(romssux,romdir);
//        strcat(romssux,arkivo[i]);
//        app_data.crc = crc32_file(romssux);
//        if (app_data.crc == crcx)
//        {
//            if ((app_data.crc == 0xD7089068)||(app_data.crc == 0xB0A7D723)||
//                (app_data.crc == 0x0CA26992)||(app_data.crc == 0x0B6EB25B)||
//                (app_data.crc == 0x06861A9C)||(app_data.crc == 0xB2F0F0B4)||
//                (app_data.crc == 0x68560DC7)||(app_data.crc == 0x0D2D721D)||
//                (app_data.crc == 0xC4134DF8)||(app_data.crc == 0xA75C42F8))
//                rom_f = 0;
//        }
//    }
//    return(0);
//}
/********************* Ready BIOS */
//int identify_bios(char *biossux)
//{
//    app_data.crc = crc32_file(biossux);
//    if (app_data.crc == 0x8016A315){
//        strcpy(odyssey2, biossux);
//        o2flag = 1;
//    }
//    if (app_data.crc == 0xE20A9F41){
//        strcpy(g7400, biossux);
//        g74flag = 1;
//    }
//    if (app_data.crc == 0xA318E8D6){
//        strcpy(c52, biossux);
//        c52flag = 1;
//    }
//    if (app_data.crc == 0x11647CA5){
//        strcpy(jopac, biossux);
//        jopflag = 1;
//    }
//    return(0);
//}

@implementation OdysseyGameCore

- (instancetype)init {
    if((self = [super init])) {
        virtualPhysicalKeyMap = @{
            @(UIKeyboardHIDUsageKeypad0) : @(RETROK_KP0),
            @(UIKeyboardHIDUsageKeypad1) : @(RETROK_KP1),
            @(UIKeyboardHIDUsageKeypad2) : @(RETROK_KP2),
            @(UIKeyboardHIDUsageKeypad3) : @(RETROK_KP3),
            @(UIKeyboardHIDUsageKeypad4) : @(RETROK_KP4),
            @(UIKeyboardHIDUsageKeypad5) : @(RETROK_KP5),
            @(UIKeyboardHIDUsageKeypad6) : @(RETROK_KP6),
            @(UIKeyboardHIDUsageKeypad7) : @(RETROK_KP7),
            @(UIKeyboardHIDUsageKeypad8) : @(RETROK_KP8),
            @(UIKeyboardHIDUsageKeypad9) : @(RETROK_KP9),

            @(UIKeyboardHIDUsageKeyboard0) : @(RETROK_0),
            @(UIKeyboardHIDUsageKeyboard1) : @(RETROK_1),
            @(UIKeyboardHIDUsageKeyboard2) : @(RETROK_2),
            @(UIKeyboardHIDUsageKeyboard3) : @(RETROK_3),
            @(UIKeyboardHIDUsageKeyboard4) : @(RETROK_4),
            @(UIKeyboardHIDUsageKeyboard5) : @(RETROK_5),
            @(UIKeyboardHIDUsageKeyboard6) : @(RETROK_6),
            @(UIKeyboardHIDUsageKeyboard7) : @(RETROK_7),
            @(UIKeyboardHIDUsageKeyboard8) : @(RETROK_8),
            @(UIKeyboardHIDUsageKeyboard9) : @(RETROK_9),
            
            @(UIKeyboardHIDUsageKeyboardA) : @(RETROK_a),
            @(UIKeyboardHIDUsageKeyboardB) : @(RETROK_b),
            @(UIKeyboardHIDUsageKeyboardC) : @(RETROK_c),
            @(UIKeyboardHIDUsageKeyboardD) : @(RETROK_d),
            @(UIKeyboardHIDUsageKeyboardE) : @(RETROK_e),
            @(UIKeyboardHIDUsageKeyboardF) : @(RETROK_f),
            @(UIKeyboardHIDUsageKeyboardG) : @(RETROK_g),
            @(UIKeyboardHIDUsageKeyboardH) : @(RETROK_h),
            @(UIKeyboardHIDUsageKeyboardI) : @(RETROK_i),
            @(UIKeyboardHIDUsageKeyboardJ) : @(RETROK_j),
            @(UIKeyboardHIDUsageKeyboardK) : @(RETROK_k),
            @(UIKeyboardHIDUsageKeyboardL) : @(RETROK_l),
            @(UIKeyboardHIDUsageKeyboardM) : @(RETROK_m),
            @(UIKeyboardHIDUsageKeyboardN) : @(RETROK_n),
            @(UIKeyboardHIDUsageKeyboardO) : @(RETROK_o),
            @(UIKeyboardHIDUsageKeyboardP) : @(RETROK_p),
            @(UIKeyboardHIDUsageKeyboardQ) : @(RETROK_q),
            @(UIKeyboardHIDUsageKeyboardR) : @(RETROK_r),
            @(UIKeyboardHIDUsageKeyboardS) : @(RETROK_s),
            @(UIKeyboardHIDUsageKeyboardT) : @(RETROK_t),
            @(UIKeyboardHIDUsageKeyboardU) : @(RETROK_u),
            @(UIKeyboardHIDUsageKeyboardV) : @(RETROK_v),
            @(UIKeyboardHIDUsageKeyboardW) : @(RETROK_w),
            @(UIKeyboardHIDUsageKeyboardX) : @(RETROK_x),
            @(UIKeyboardHIDUsageKeyboardY) : @(RETROK_y),
            @(UIKeyboardHIDUsageKeyboardZ) : @(RETROK_z),
            
            @(UIKeyboardHIDUsageKeypadAsterisk) : @(RETROK_KP_MULTIPLY),
            @(UIKeyboardHIDUsageKeypadEnter) : @(RETROK_KP_ENTER),
            @(UIKeyboardHIDUsageKeypadEqualSign) : @(RETROK_KP_EQUALS),
            @(UIKeyboardHIDUsageKeypadPlus) : @(RETROK_KP_PLUS),
            @(UIKeyboardHIDUsageKeypadHyphen) : @(RETROK_KP_MINUS),
            @(UIKeyboardHIDUsageKeypadComma) : @(RETROK_COMMA),
            @(UIKeyboardHIDUsageKeypadPeriod) : @(RETROK_KP_PERIOD),
            @(UIKeyboardHIDUsageKeypadSlash) : @(RETROK_KP_DIVIDE),
            
            @(UIKeyboardHIDUsageKeyboardScrollLock) : @(RETROK_SCROLLOCK),
            @(UIKeyboardHIDUsageKeyboardCapsLock) : @(RETROK_CAPSLOCK),
            @(UIKeyboardHIDUsageKeypadNumLock) : @(RETROK_NUMLOCK),

            @(UIKeyboardHIDUsageKeyboardSpacebar) : @(RETROK_SPACE),
            @(UIKeyboardHIDUsageKeyboardDeleteOrBackspace) : @(RETROK_BACKSPACE),
            @(UIKeyboardHIDUsageKeyboardGraveAccentAndTilde) : @(RETROK_QUOTE),
            @(UIKeyboardHIDUsageKeyboardDeleteForward) : @(RETROK_DELETE),
            @(UIKeyboardHIDUsageKeyboardTab) : @(RETROK_TAB),
            @(UIKeyboardHIDUsageKeyboardPause) : @(RETROK_PAUSE),
//            @(UIKeyboardHIDUsageKeyboardSlash) : @(RETROK_QUESTION),
            @(UIKeyboardHIDUsageKeyboardPeriod) : @(RETROK_PERIOD),
            @(UIKeyboardHIDUsageKeyboardReturnOrEnter) : @(RETROK_RETURN),
            @(UIKeyboardHIDUsageKeyboardHyphen) : @(RETROK_MINUS),
            @(UIKeyboardHIDUsageKeyboardSlash) : @(RETROK_SLASH),

            @(UIKeyboardHIDUsageKeyboardOpenBracket) : @(RETROK_LEFTBRACKET),
            @(UIKeyboardHIDUsageKeyboardBackslash) : @(RETROK_BACKSLASH),
//            @(UIKeyboardHIDUsageKeyboardBackslash) : @(RETROK_BAR), // |
            @(UIKeyboardHIDUsageKeyboardCloseBracket) : @(RETROK_RIGHTBRACKET),
            @(UIKeyboardHIDUsageKeyboardQuote) : @(RETROK_QUOTEDBL),

            @(UIKeyboardHIDUsageKeyboardLeftAlt) : @(RETROK_LALT),
            @(UIKeyboardHIDUsageKeyboardLeftGUI) : @(RETROK_LMETA), // RETROK_LSUPER
            @(UIKeyboardHIDUsageKeyboardLeftShift) : @(RETROK_LSHIFT),
            @(UIKeyboardHIDUsageKeyboardLeftControl) : @(RETROK_LCTRL),

            @(UIKeyboardHIDUsageKeyboardRightAlt) : @(RETROK_RALT),
            @(UIKeyboardHIDUsageKeyboardRightGUI) : @(RETROK_RMETA),
            @(UIKeyboardHIDUsageKeyboardRightShift) : @(RETROK_RSHIFT),
            @(UIKeyboardHIDUsageKeyboardRightControl) : @(RETROK_RCTRL),
            
            @(UIKeyboardHIDUsageKeyboardLeftArrow) : @(RETROK_LEFT),
            @(UIKeyboardHIDUsageKeyboardRightArrow) : @(RETROK_RIGHT),
            @(UIKeyboardHIDUsageKeyboardUpArrow) : @(RETROK_UP),
            @(UIKeyboardHIDUsageKeyboardDownArrow) : @(RETROK_DOWN),

            @(UIKeyboardHIDUsageKeyboardF1) : @(RETROK_F1),
            @(UIKeyboardHIDUsageKeyboardF2) : @(RETROK_F2),
            @(UIKeyboardHIDUsageKeyboardF3) : @(RETROK_F3),
            @(UIKeyboardHIDUsageKeyboardF4) : @(RETROK_F4),
            @(UIKeyboardHIDUsageKeyboardF5) : @(RETROK_F5),
            @(UIKeyboardHIDUsageKeyboardF6) : @(RETROK_F6),
            @(UIKeyboardHIDUsageKeyboardF7) : @(RETROK_F7),
            @(UIKeyboardHIDUsageKeyboardF8) : @(RETROK_F8),
            @(UIKeyboardHIDUsageKeyboardF9) : @(RETROK_F9),
            @(UIKeyboardHIDUsageKeyboardF10) : @(RETROK_F10),
            @(UIKeyboardHIDUsageKeyboardF11) : @(RETROK_F11),
            @(UIKeyboardHIDUsageKeyboardF12) : @(RETROK_F12),
            @(UIKeyboardHIDUsageKeyboardF13) : @(RETROK_F13),
            @(UIKeyboardHIDUsageKeyboardF14) : @(RETROK_F14),
            @(UIKeyboardHIDUsageKeyboardF15) : @(RETROK_F15),
            
            @(UIKeyboardHIDUsageKeyboardHelp) : @(RETROK_HELP),
            @(UIKeyboardHIDUsageKeyboardPrintScreen) : @(RETROK_PRINT),
            
            @(UIKeyboardHIDUsageKeyboardUndo) : @(RETROK_UNDO),
            
            @(UIKeyboardHIDUsageKeyboardPageUp) : @(RETROK_PAGEUP),
            @(UIKeyboardHIDUsageKeyboardPageDown) : @(RETROK_PAGEDOWN),
            @(UIKeyboardHIDUsageKeyboardInsert) : @(RETROK_INSERT),
            @(UIKeyboardHIDUsageKeyboardHome) : @(RETROK_HOME),
            @(UIKeyboardHIDUsageKeyboardEnd) : @(RETROK_END),
            
            @(UIKeyboardHIDUsageKeyboardPower) : @(RETROK_POWER),
            @(UIKeyboardHIDUsageKeyboardMenu) : @(RETROK_MENU),
            @(UIKeyboardHIDUsageKeyboardClearOrAgain) : @(RETROK_CLEAR),

            // TODO: There's more codes to add if you want 100%
        };
    }
    
    return self;
}

- (void)dealloc {
    close_audio();
	close_voice();
	close_display();
	retro_destroybmp();
    if(mbmp) { free(mbmp); }
}

#pragma mark - Execution

-(NSString*)systemIdentifier {
    return @"com.provenance.odyssey2";
}

-(NSString*)biosDirectoryPath {
    return self.BIOSPath;
}

- (BOOL)loadFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    RLOOP=1;
    
	static char file[MAXC], attr[MAXC], val[MAXC], *p, *binver;
    
    app_data.debug = 0;
	app_data.stick[0] = app_data.stick[1] = 1;
	app_data.sticknumber[0] = app_data.sticknumber[1] = 0;
	set_defjoykeys(0,0);
	set_defjoykeys(1,1);
	set_defsystemkeys();
	app_data.bank = 0;
	app_data.limit = 1;
	app_data.sound_en = 1;
	app_data.speed = 100;
	app_data.wsize = 2;
	app_data.fullscreen = 0;
	app_data.scanlines = 0;
	app_data.voice = 1;
	app_data.window_title = "O2EM v" O2EM_VERSION;
	app_data.svolume = 100;
	app_data.vvolume = 100;
	app_data.filter = 0;
	app_data.exrom = 0;
	app_data.three_k = 0;
	app_data.crc = 0;
	app_data.scshot = scshot;
	app_data.statefile = statefile;
	app_data.euro = 0;
	app_data.openb = 0;
	app_data.vpp = 0;
	app_data.bios = 0;
	app_data.scoretype = 0;
	app_data.scoreaddress = 0;
	app_data.default_highscore = 0;
	app_data.breakpoint = 65535;
	app_data.megaxrom = 0;
	strcpy(file,"");
	strcpy(file_l,"");
	strcpy(bios_l,"");
    strcpy(bios,"");
	strcpy(scshot,"");
	strcpy(statefile,"");
    strcpy(xrom,"");
	strcpy(scorefile,"highscore.txt");
	//read_default_config();
    
    init_audio();
    
    app_data.crc = crc32_file([path fileSystemRepresentation]);
    
    //suck_bios();
    o2flag = 1;
    
    crcx = app_data.crc;
    //suck_roms();
    
    NSString *biosROM = [[self BIOSPath] stringByAppendingPathComponent:@"o2rom.bin"];
    int status = EXIT_SUCCESS;
    status = load_bios([biosROM fileSystemRepresentation]);
    if (status == EXIT_FAILURE) {
        ELOG(@"Failed to open file");
        if(error != NULL) {
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: @"Failed to load bios.",
                NSLocalizedFailureReasonErrorKey: @"Odyssey2 failed to load BIOS.",
                NSLocalizedRecoverySuggestionErrorKey: @"Check that file isn't corrupt and in format Odyssey2 supports."
            };

            NSError *newError = [NSError errorWithDomain:PVEmulatorCoreErrorDomain
                                                    code:PVEmulatorCoreErrorCodeCouldNotLoadRom
                                                userInfo:userInfo];

            *error = newError;
        }
        return NO;
    }
    
	status = load_cart([path fileSystemRepresentation]);
    if (status == EXIT_FAILURE) {
        ELOG(@"Failed to open file");
        if(error != NULL) {
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: @"Failed to load rom.",
                NSLocalizedFailureReasonErrorKey: @"Odyssey2 failed to load rom.",
                NSLocalizedRecoverySuggestionErrorKey: @"Check that file isn't corrupt and in format Odyssey2 supports."
            };

            NSError *newError = [NSError errorWithDomain:PVEmulatorCoreErrorDomain
                                                    code:PVEmulatorCoreErrorCodeCouldNotLoadRom
                                                userInfo:userInfo];

            *error = newError;
        }
        return NO;
    }
	//if (app_data.voice) load_voice_samples(path2);
    
	init_display();
    
	init_cpu();
    
	init_system();
    
    set_score(app_data.scoretype, app_data.scoreaddress, app_data.default_highscore);
    
    return YES;
}

- (void)executeFrameSkippingFrame: (BOOL) skip {
//    if (self.controller1 || self.controller2) {
//        [self pollControllers];
//    }
    //run();
    cpu_exec();

    int len = evblclk == EVBLCLK_NTSC ? 44100/60 : 44100/50;

    // Convert 8u to 16s
    if(!skip) {
        for(int i = 0; i < len; i++)
        {
            int16_t sample16 = (soundBuffer[i] - 128 ) << 8;

            [[self ringBufferAtIndex:0] write:&sample16 maxLength:2];
        }
    }

    RLOOP=1;
}

- (void)executeFrame {
    [self executeFrameSkippingFrame:NO];
}

- (void)resetEmulation {
    init_cpu();
    init_roms();
    init_vpp();
    clearscr();
    if (mbmp) {
        free(mbmp);
        mbmp = nil;
    }
}

//- (void)stopEmulation
//{
//    RLOOP = 0;
//    [super stopEmulation];
//}

@end
