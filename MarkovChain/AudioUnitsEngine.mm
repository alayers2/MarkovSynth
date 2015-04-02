//
//  AudioUnitsEngine.m
//  AUPlayer
//
//  Created by willpirkle on 4/18/11.
//  Copyright 2011 University of Miami. All rights reserved.
//

#import "AudioUnitsEngine.h"


#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

//#define MAX_VOICES 16

@implementation AudioUnitsEngine
{
    AEBlockChannel *synthCallback;
}


+ (AudioStreamBasicDescription)nonInterleavedFloatStereoAudioDescriptionHalfRate {
    AudioStreamBasicDescription audioDescription;
    memset(&audioDescription, 0, sizeof(audioDescription));
    audioDescription.mFormatID          = kAudioFormatLinearPCM;
    audioDescription.mFormatFlags       = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
    audioDescription.mChannelsPerFrame  = 2;
    audioDescription.mBytesPerPacket    = sizeof(float);
    audioDescription.mFramesPerPacket   = 1;
    audioDescription.mBytesPerFrame     = sizeof(float);
    audioDescription.mBitsPerChannel    = 8 * sizeof(float);
    audioDescription.mSampleRate        = 22050.0;
    return audioDescription;
}
// default initializer
- (id)init
{
	self = [super init];
    if (self) 
	{
        // set our defaults
		// end init
        // load up voices
        effectsArray = [[NSMutableArray alloc] init];
        effectsDictionary = [[NSMutableDictionary alloc] init];
        
        CMiniSynthVoice* pVoice;
        MAX_VOICES = 16;
        for(int i=0; i<MAX_VOICES; i++)
        {
            pVoice = new CMiniSynthVoice;
            pVoice->setSampleRate((double)22050);
            pVoice->prepareForPlay();
            pVoice->update();
            m_VoicePtrStack1.push_back(pVoice);
            
//            AYAVoiceThread *vThread = new AYAVoiceThread((CVoice*)pVoice);
//            m_VoiceThreadStack.push_back(vThread);
           
        }
        
        
        self.audioController = [[AEAudioController alloc]
                                initWithAudioDescription:[AudioUnitsEngine nonInterleavedFloatStereoAudioDescriptionHalfRate]
                                inputEnabled:NO];
        
        
        synthCallback = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp  *time,
                                                               UInt32 frames,
                                                               AudioBufferList *audio) {
            for ( int i=0; i<frames; i++ ) {
                
                // do left channel; convert to float -1.0 to +1.0
                // do the LEFT processing - here is pass-thru
                double dLeftAccum = 0.0;
                
                for(int j=0; j<MAX_VOICES; j++)
                {
                    double dLeft, dRight;
                    CVoice *pVoice = m_VoicePtrStack1[j];
                    pVoice->doVoice(dLeft, dRight);
                    dLeftAccum += dLeft;
                }
                

                
                float fLeftAccum = float(dLeftAccum);
                
                for (RLAudioEffect *effect in effectsArray) {
                    [effect processAudioFrameInPlace:(float*)&fLeftAccum];
                }


                ((float*)audio->mBuffers[0].mData)[i] = fLeftAccum;                
                ((float*)audio->mBuffers[1].mData)[i] = fLeftAccum;
                
            }
        }];
        
        [self.audioController addChannels:@[synthCallback]];
    }
	
    return self;
}

+(id)getAudioUnitsEngine{
    if (self) {
        return self;
    }else
        return nil;
}


-(void)setNoteOn:(int)notenumber{
    CMiniSynthVoice* pVoice;
	m_VoiceIterator1 = m_VoicePtrStack1.begin();
    
	bool bStealNote = true;
	for(int i=0; i<MAX_VOICES; i++)
	{
		pVoice =  m_VoicePtrStack1[i];
		// if we have a free voice, turn on
		if(!pVoice->m_bNoteOn)
		{
			m_VoiceIterator1 = m_VoicePtrStack1.erase(m_VoiceIterator1);
			m_VoicePtrStack1.push_back(pVoice);
            
			pVoice->noteOn(notenumber, 60, midiMIDIFreqTable[notenumber], m_dLastNoteFrequency);
            
			pVoice->setSustainOverride(false);
            
            
			// save
			m_dLastNoteFrequency = midiMIDIFreqTable[notenumber];
			bStealNote = false;
			break;
		}
		else {
			m_VoiceIterator1++;
		}
	}
	if(bStealNote)
	{
		// steal oldest note
		CMiniSynthVoice* pVoice = m_VoicePtrStack1[0]; // always the oldest
		
		m_VoicePtrStack1.erase(m_VoicePtrStack1.begin());
		m_VoicePtrStack1.push_back(pVoice);
        
		pVoice->noteOn(notenumber, 60, midiMIDIFreqTable[notenumber], m_dLastNoteFrequency);
		pVoice->setSustainOverride(false);
    
        
		// save
		m_dLastNoteFrequency = midiMIDIFreqTable[notenumber];
	}
}

-(void)setNoteOff:(int)notenumber{
    
    // find and turn off
	m_VoiceIterator1 = m_VoicePtrStack1.begin();
    
	for(int i=0; i<MAX_VOICES; i++)
	{
		CMiniSynthVoice* pVoice = m_VoicePtrStack1[i];
		
		// find matching source/destination pairs
		if(pVoice->canNoteOff() && pVoice->m_uMIDINoteNumber == notenumber)
		{
			pVoice->noteOff(notenumber);
			
			// may have multiple notes sustaining; this ensures the oldest
			// note gets the event
			break;
		}
		
		m_VoiceIterator1++;
	}
}

- (void)startAUGraph
{
    NSError *errorAudioSetup = NULL;
    BOOL result = [self.audioController start:&errorAudioSetup];
    if ( !result ) {
        NSLog(@"Error starting audio engine: %@", errorAudioSetup.localizedDescription);
    }
}

// stops render
- (void)stopAUGraph
{
    [self.audioController stop];
}

#pragma mark - Effects Array Method

-(void)addEffectorEffectGroupToArray:(RLAudioEffect *)effect forKey:(NSString *)key{
    [effectsDictionary setObject:effect forKey:key];
    [effectsArray addObject:effect];
    numEffectsInArray = [effectsArray count];
}

-(void)removeEffectFromArrayForKey:(NSString *)key{
    RLAudioEffect *effect = [effectsDictionary objectForKey:key];
    [effectsArray removeObject:effect];
    numEffectsInArray = [effectsArray count];
}

-(RLAudioEffect*)retrieveEffectFromGroupForKey:(NSString *)key{
    RLAudioEffect* effect =[effectsDictionary objectForKey:key];
    return effect;
}


@end
