//
//  AYAMainViewController.m
//  MarkovChain
//
//  Created by Andrew Ayers on 4/10/14.
//  Copyright (c) 2014 AyersAudio. All rights reserved.
//

#import "AYAMainViewController.h"

typedef NS_ENUM(NSInteger, connectionType){
    kConnectionTypeLine,
    kConnectionTypeCircle,
};

@interface AYAMainViewController ()

@end

@implementation AYAMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // create frequency table for MIDI support
        // make frequency (Hz) table
        currentOctave = 4;
        double k = 1.059463094359;	// 12th root of 2
        double a = 6.875;	// a
        a *= k;	// b
        a *= k;	// bb
        a *= k;	// c, frequency of midi note 0
        for (int i = 0; i < 127; i++)	// 128 midi notes
        {
            // Hz Table
            m_MIDIFreqTable[i] = (float)a;
            
            // update for loop . . .
            a *= k;
        }
        m_uOsc1Waveform = 3;
        m_dDetune_cents = 0.0;
        m_uOsc2Waveform = 4;
        m_fOsc1Level = 25.5;
        m_fOsc2Level = 66.0;
        m_uDetuneSemitones = 0;
        m_nOctave = 0;
        m_dFcControl = 2100.0;
        m_dRate_LFO = 2.0;
        m_dAttackTime_mSec = 2000.0;
        m_dPulseWidth_Pct = 20;
        m_dPortamentoTime_mSec = 0;
        m_dQControl = 1.0;
        m_dOscLFOIntensity = 0.0;
        m_dDecayReleaseTime_mSec = 1000.0;
        m_uModMode = 0;
        //Delay
        m_fFeedback_pct = 50.0;
        m_fDelay_ms = 148.0;
        m_fWetLevel_pct = 84.0;
        
        m_dHSRatio = 1.00;
        m_dOscEGIntensity = 0.0;
        m_dFilterEGIntensity = 0.0;
        m_dFilterLFOIntensity = 0.0;
        
        m_dSustainLevel = 0.5;
        m_fDecay = 0.5;
        m_fBandwidth = 0.9995;
        m_fDamping = 0.005;
        m_fWetPct = 50.0;
        m_dNoiseOsc_dB = -96.00;
        m_dLFOAmpIntensity = 0.0;
        m_dLFOPanIntensity = 0.0;
        m_uLFO_Waveform = 0;
        m_dDCAEGIntensity = 1.00;
        //Distortion Stuff
        m_fArcTanKPos = 16.2;
        m_fArcTanKNeg = 13.15;
        m_nStages = 1;
        m_uInvertStages = 0;
        m_fGain = 3.0;
        m_dAmplitude_dB = 0.0;
        
        //Overall Synth Stuff
        m_uLegatoMode = 0;
        m_nPitchBendRange = 1;
        m_uResetToZero = 0;
        m_uFilterKeyTrack = 0;
        m_dFilterKeyTrackIntensity = 1.0;
        m_uVelocityToAttackScaling = 0;
        m_uNoteNumberToDecayScaling = 0;
        
        //Timbre
        m_uTimbreSelection = 0;
        
    }
    return self;
}
-(void)updateMiniSynth
{
    CMiniSynthVoice* pVoice;
    for(int i=0; i<4; i++)
    {
        timbre *pTimbre = &timbre1;
        pVoice = auEngine.auTrack_1_PlaybackInfo.m_VoicePtrStack1[i];

        
        
        
        pTimbre->Amplitude_dB = m_dAmplitude_dB;
        pVoice->setDCAAmplitude_dB(pTimbre->Amplitude_dB);
        
        pTimbre->Detune_cents = m_dDetune_cents;
        pVoice->setDetuneCents(pTimbre->Detune_cents);
        
        pTimbre->Octave = m_nOctave;
        pVoice->setOctave(pTimbre->Octave);
        
        pTimbre->Osc1Waveform = m_uOsc1Waveform;
        pVoice->setOsc1Waveform(pTimbre->Osc1Waveform);
        
        pTimbre->Osc2Waveform = m_uOsc2Waveform;
        pVoice->setOsc2Waveform(pTimbre->Osc2Waveform);
        
        pTimbre->Osc3Waveform = m_uOsc3Waveform;
        pVoice->setOsc3Waveform(pTimbre->Osc3Waveform);
        
        pTimbre->Osc4Waveform = m_uOsc4Waveform;
        pVoice->setOsc4Waveform(pTimbre->Osc4Waveform);
        
        pTimbre->Osc1Level = m_fOsc1Level;
        pVoice->setOsc1Level(pTimbre->Osc1Level);
        
        pTimbre->Osc2Level = m_fOsc2Level;
        pVoice->setOsc2Level(pTimbre->Osc2Level);
        
        pTimbre->Osc3Level = m_fOsc3Level;
        pVoice->setOsc3Level(pTimbre->Osc3Level);
        
        pTimbre->Osc4Level = m_fOsc4Level;
        pVoice->setOsc4Level(pTimbre->Osc4Level);
        
        pTimbre->DetuneSemitones = m_uDetuneSemitones;
        pVoice->setOscDetuneSemitones(m_uDetuneSemitones);
        
        pTimbre->ModMode = m_uModMode;
        pVoice->setModMode(pTimbre->ModMode);
        
        pTimbre->LegatoMode = (bool)m_uLegatoMode;
        pVoice->setEG1LegatoMode(pTimbre->LegatoMode);
        
        pTimbre->ResetToZero = (bool)m_uResetToZero;
        pVoice->setEG1ResetToZero(pTimbre->ResetToZero);
        
        pTimbre->PitchBendRange = m_nPitchBendRange;
        pVoice->setPitchBendModRange(pTimbre->PitchBendRange);
        // PORTAMENTO!
        
        pTimbre->PortamentoTime_mSec = m_dPortamentoTime_mSec;
        pVoice->setPortamentoTime_mSec(pTimbre->PortamentoTime_mSec);
        
        pTimbre->HSRatio = m_dHSRatio;
        pVoice->setHSRatio(pTimbre->HSRatio);
        
        pTimbre->OscEGIntensity = m_dOscEGIntensity;
        pVoice->setOscEGIntensity(pTimbre->OscEGIntensity);
        
        pTimbre->NoiseOsc_dB = m_dNoiseOsc_dB;
        pVoice->setOscAmplitude_dB(3, pTimbre->NoiseOsc_dB);
        // col 2
        pTimbre->FcControl = m_dFcControl;
        pVoice->setFilter1Cutoff(pTimbre->FcControl);
        
        pTimbre->QControl = m_dQControl;
        pVoice->setFilter1Q(pTimbre->QControl);
        
        pTimbre->FilterEGIntensity = m_dFilterEGIntensity;
        pVoice->setFilter1EGIntensity(pTimbre->FilterEGIntensity);
        
        pTimbre->LFOAmpIntensity = m_dLFOAmpIntensity;
        pVoice->setLFO1DCAAmpModIntensity(pTimbre->LFOAmpIntensity);
        // col 3
        pTimbre->Rate_LFO = m_dRate_LFO;
        pVoice->setLFO1Rate(pTimbre->Rate_LFO);
        
        pTimbre->OscLFOIntensity = m_dOscLFOIntensity;
        pVoice->setOscLFOIntensity(pTimbre->OscLFOIntensity);
        
        pTimbre->FilterLFOIntensity = m_dFilterLFOIntensity;
        pVoice->setFilter1LFOIntensity(pTimbre->FilterLFOIntensity);
        
        pTimbre->LFOWaveform = m_uLFO_Waveform;
        pVoice->setLFO1Waveform(pTimbre->LFOWaveform);
        
        pTimbre->LFOPanIntensity = m_dLFOPanIntensity;
        pVoice->setDCAPanLFOIntensity(pTimbre->LFOPanIntensity);
        // col 4
        
        pTimbre->AttackTime_mSec = m_dAttackTime_mSec;
        pVoice->setEG1AttackTime_mSec(m_dAttackTime_mSec);
        
        pTimbre->DecayReleaseTime_mSec = m_dDecayReleaseTime_mSec;
        pVoice->setEG1DecayTime_mSec(m_dDecayReleaseTime_mSec);
        pVoice->setEG1ReleaseTime_mSec(m_dDecayReleaseTime_mSec);
        
        pTimbre->SustainLevel = m_dSustainLevel;
        pVoice->setEG1SustainLevel(m_dSustainLevel);
        
        pTimbre->DCAEGIntensity = m_dDCAEGIntensity;
        pVoice->setDCAEGIntensity(m_dDCAEGIntensity);
        // turn on/off and Intensity; filter key track
        
        pTimbre->FilterKeyTrack = m_uFilterKeyTrack;
        pVoice->enableFilterKeyTrack(m_uFilterKeyTrack);
        
        pTimbre->FilterKeyTrackIntensity = m_dFilterKeyTrackIntensity;
        pVoice->setFilterKeyTrackIntensity(m_dFilterKeyTrackIntensity);
        // turn on/off vel->attack and note->decay scaling
        pTimbre->VelocityToAttackScaling = m_uVelocityToAttackScaling;
        pVoice->enableVelocityToAttackScaling(m_uVelocityToAttackScaling);
        
        pTimbre->NoteNumberToDecayScaling = m_uNoteNumberToDecayScaling;
        pVoice->enableMIDINoteNumberToDecayScaling(m_uNoteNumberToDecayScaling);
        
        pTimbre->PulseWidth_Pct = m_dPulseWidth_Pct;
        pVoice->setPulseWidthControl(m_dPulseWidth_Pct);
        
        pTimbre->ArcTanKNeg = m_fArcTanKNeg;
        pVoice->setArcTanKNeg(m_fArcTanKNeg);
        
        pTimbre->ArcTanKPos = m_fArcTanKPos;
        pVoice->setArcTanKPos(m_fArcTanKPos);
        
        pTimbre->Stages = m_nStages;
        pVoice->setWaveshapeStages(m_nStages);
        
        pTimbre->InvertStages = m_uInvertStages;
        pVoice->setInvertStages(m_uInvertStages);
        
        pTimbre->Gain = m_fGain;
        pVoice->setGain(m_fGain);
        
        pVoice->setLFO1DCAAmpModIntensity(m_dLFOAmpIntensity);
        
        pVoice->setGain(1.0);
        
        pVoice->setModMode(0);
        pVoice->update();
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize the engine to render our synthesizer
    auEngine = [[AudioUnitsEngine alloc] init];
    // Call the initial update to set the parameters to the values defined in this class
    [self updateMiniSynth];
    // We always call the stop before initializing it just to make sure
    [auEngine stopAUGraph];
    // Use the wave file to set up our CASBD because I'm lazy
	[auEngine initPlaybackAUGraphWithFile:@"9" ofType:@"wav" isCompressed:NO];
    // Start the rendering
	[auEngine startAUGraph];
    
    // Create our connection Manager
    connectionManager = [[AYAConnectionManager alloc] init];
    
    // Initialize the nodes array
    nodes = [[NSMutableArray alloc] init];
    
    //Create the background layer for the main view.
    CAGradientLayer *backgroundLayer = [[CAGradientLayer alloc] init];
    backgroundLayer.frame = self.view.bounds;
    
    // Set up our two colors for the nice gradient
    UIColor *colorOne = [UIColor colorWithRed:74.0/255.0 green:74.0/255.0 blue:74.0/255.0 alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:43.0/255.0 green:43.0/255.0 blue:43.0/255.0 alpha:1.0];
    NSArray *colors =  @[(id)colorOne.CGColor, (id)colorTwo.CGColor]; //<- Literals!
    
    // Setup color stop locations
    NSNumber *stopOne = [NSNumber numberWithFloat:0.1];
    NSNumber *stopTwo = [NSNumber numberWithFloat:0.8];
    NSArray *locations = @[stopOne, stopTwo]; //<- Literals!
    
    // Finish Background Layer stuff
    backgroundLayer.colors = colors;
    backgroundLayer.locations = locations;
    [self.view.layer addSublayer:backgroundLayer];
    
    // Make sure that the mode selection view is always in front of the background layer
    [self.view bringSubviewToFront:modeSelection];
    
}

-(void)viewDidAppear:(BOOL)animated{
    // Double tap recognizer to add node.
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setNumberOfTapsRequired:2];
    [tapGestureRecognizer addTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    // Pan gesture to move node. I don't think we need this.
//    UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
//    [panGestureRecognizer setMinimumNumberOfTouches:1];
//    [panGestureRecognizer setMaximumNumberOfTouches:1];
//    [panGestureRecognizer addTarget:self action:@selector(handlePan:)];
//    [self.view addGestureRecognizer:panGestureRecognizer];
}

-(void)handleTap:(UITapGestureRecognizer*)sender{
    
    // If the mode selection is 0, we are in node mode, so we'll create a node for a double tap
    if (modeSelection.selectedSegmentIndex == 0) {
        // Init our node view and assign it to the place that was tapped.
        AYANodeView *nodeView = [[AYANodeView alloc] initWithFrame:CGRectMake(100, 100, 75, 75)];
        [nodeView setCenter:[sender locationInView:self.view]];
        // We need to be the node's delegate as well.
        [nodeView setDelegate:self];
    
        // Pan gesture to move nodes
        UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        [panGestureRecognizer setMinimumNumberOfTouches:1];
        [panGestureRecognizer setMaximumNumberOfTouches:1];
        [panGestureRecognizer addTarget:self action:@selector(handlePan:)];
        [nodeView addGestureRecognizer:panGestureRecognizer];
        
        // Single tap recognizer to activate nodes
        UITapGestureRecognizer* nodeTapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        [nodeTapGestureRecognizer setNumberOfTouchesRequired:1];
        [nodeTapGestureRecognizer setNumberOfTapsRequired:1];
        [nodeTapGestureRecognizer addTarget:self action:@selector(handleNodeTap:)];
        [nodeView addGestureRecognizer:nodeTapGestureRecognizer];
        
        // Double tap for connection creation, this is only until I get drawing connections done.
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        [tapGestureRecognizer setNumberOfTouchesRequired:1];
        [tapGestureRecognizer setNumberOfTapsRequired:2];
        [tapGestureRecognizer addTarget:self action:@selector(handleTap:)];
        [nodeView addGestureRecognizer:tapGestureRecognizer];
        
        // Long press to bring up form sheet to edit properties. Rob had a good idea of using a pinch or drag from a node to present the controls that this shows.
        UILongPressGestureRecognizer* longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
        [longPressGestureRecognizer setAllowableMovement:10.0f];
        [longPressGestureRecognizer setMinimumPressDuration:1.0f];
        [longPressGestureRecognizer setNumberOfTouchesRequired:1];
        [longPressGestureRecognizer addTarget:self action:@selector(handlePress:)];
        [nodeView addGestureRecognizer:longPressGestureRecognizer];
        
        // Add the nodeView to the array we use to keep track of all the nodes.
        [nodes addObject:nodeView];
        
        // Finally, after much ado, we add the view to the mainVC
        [self.view addSubview:nodeView];
        
    // modeselection 1 is the connection part
    }else if(modeSelection.selectedSegmentIndex == 1){
        
        // If no startview, set startview so we know where the connection will come from.
        if (startView == nil && [sender.view isKindOfClass:[AYANodeView class]]) {
            startView = (AYANodeView*)[sender view];
            // Change the startview's background as a visual helper.
            [startView.backgroundLayer setBackgroundColor:[UIColor colorWithRed:100.0/255.0 green:149.0/255.0 blue:155.0/255.0 alpha:1.0].CGColor];
        
        // Or, we already have a startview and we need to create the connection (not to ourselves).
        }else if([sender.view isKindOfClass:[AYANodeView class]] && !CGRectEqualToRect(sender.view.frame,startView.frame)){
            [CATransaction setDisableActions:YES];
            
            // Create a line layer
            CALayer *lineLayer = [CALayer layer];
            lineLayer.opacity = 0.2;
            lineLayer.backgroundColor = [UIColor orangeColor].CGColor;
            
            // It will be a line connection
            [lineLayer setValue:@(kConnectionTypeLine) forKeyPath:@"connectionType"];
            
            // This is the data model of a connection that lives behind the visualization conceptually
            AYAConnection *connection = [[AYAConnection alloc] init];
            [connection setLineLayer:lineLayer];
            [connection setStartView:startView];
            [connection setEndView:(AYANodeView*)[sender view]];
            [connection setProbability:(arc4random_uniform(500)/1000.0 + 0.5)];
            [[startView connectionArray] addObject:connection];
            
            // Add our layer
            [startView.layer addSublayer:lineLayer];
            
            // Get it set up to be positioned and referenced
            CGPoint pos = startView.center;
            CGPoint target = [sender view].center;
            target.x -= pos.x;
            target.y -= pos.y;
            // Put the layer in the right place.
            [self setLayerToLineFromAToB:lineLayer forA:CGPointZero andB:target andLineWidth:8];
            
            // Add the nice gradient animation to the lines as well.
            UIColor *colorOne = [UIColor colorWithRed:255.0/255.0 green:149.0/255.0 blue:0.0/255.0 alpha:1.0];
            UIColor *colorTwo = [UIColor colorWithRed:255.0/255.0 green:94.0/255.0 blue:58.0/255.0 alpha:1.0];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"colors"];
            animation.duration = 5.0f;
            animation.delegate =self;
            animation.fromValue = colorOne;
            animation.toValue = colorTwo;
            [animation setAutoreverses:YES];
            [animation setRepeatCount:10000];
            [lineLayer addAnimation:animation forKey:@"animateColors"];
            
            [CATransaction setDisableActions:NO];
            
            // Remove the special coloring on the startview's background
            [startView.backgroundLayer setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:149.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor];
            
            // reset startview to nil
            startView = nil;
            
        // We're making a connection, but to self.
        }else if([sender.view isKindOfClass:[AYANodeView class]] && CGRectEqualToRect(sender.view.frame,startView.frame)){
            // Set up the shape of the circle
            int radius = 60;
            CAShapeLayer *circle = [CAShapeLayer layer];
            // Make a circular shape
            circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(sender.view.bounds.size.width-radius, sender.view.bounds.size.height/2.0, 1.5*radius, 2.0*radius)
                                                     cornerRadius:radius].CGPath;
            // Center the shape in self.view
            circle.position = CGPointMake(0.0, 0.0);
            
            // Configure the apperence of the circle
            circle.opacity = 0.2;
            circle.fillColor = [UIColor clearColor].CGColor;
            circle.strokeColor = [UIColor orangeColor].CGColor;
            circle.lineWidth = 5;
            
            // set the connection type.
            [circle setValue:@(kConnectionTypeCircle) forKeyPath:@"connectionType"];

            //add to connection array;
            AYAConnection *connection = [[AYAConnection alloc] init];
            [connection setLineLayer:circle];
            [connection setStartView:startView];
            [connection setEndView:(AYANodeView*)[sender view]];
            [connection setProbability:(arc4random_uniform(1000)/1000.0)];

            [[startView connectionArray] addObject:connection];
            // Add to parent layer
            [sender.view.layer addSublayer:circle];
            
            //Gradient stuff
            UIColor *colorOne = [UIColor colorWithRed:255.0/255.0 green:149.0/255.0 blue:0.0/255.0 alpha:1.0];
            UIColor *colorTwo = [UIColor colorWithRed:255.0/255.0 green:94.0/255.0 blue:58.0/255.0 alpha:1.0];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"colors"];
            animation.duration = 5.0f;
            animation.delegate =self;
            animation.fromValue = colorOne;
            animation.toValue = colorTwo;
            [animation setAutoreverses:YES];
            [animation setRepeatCount:10000];
            [circle addAnimation:animation forKey:@"animateColors"];
            
            [startView.backgroundLayer setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:149.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor];

            startView = nil;

        }
    }
    
}

-(void)handleNodeTap:(UITapGestureRecognizer*)sender{
    [(AYANodeView*)sender.view recievedEvent];
}

-(void)setLayerToLineFromAToB:(CALayer *)layer forA:(CGPoint)a andB:(CGPoint)b andLineWidth:(CGFloat)lineWidth
{
    CGPoint center = { static_cast<CGFloat>(0.5 * (a.x + b.x)+ [layer superlayer].bounds.size.width / 2.0), static_cast<CGFloat>(0.5 * (a.y + b.y) + [layer superlayer].bounds.size.height / 2.0)};
    CGFloat length = sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
    CGFloat angle = atan2(a.y - b.y, a.x - b.x);
    
    layer.position = center;
    layer.bounds = (CGRect) { {0, 0}, { length + lineWidth, lineWidth } };
    layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1);
}

-(void)handlePan:(UIPanGestureRecognizer*)sender{
    if (modeSelection.selectedSegmentIndex == 0 && [sender.view isKindOfClass:[AYANodeView class]]) {
        CGPoint translation = [sender translationInView:self.view];
        sender.view.center = CGPointMake(sender.view.center.x + translation.x,sender.view.center.y + translation.y);
        [sender setTranslation:CGPointMake(0, 0) inView:self.view];
        [self updateLinesForView:(AYANodeView*)sender.view];
    }

}

-(void)handlePress:(UILongPressGestureRecognizer*)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"longPress");
        AYATableViewController *detailVC = [[AYATableViewController alloc] init];
        UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:detailVC];
        [detailVC setModalPresentationStyle:UIModalPresentationFormSheet];
        [detailVC setPresentingNode:(AYANodeView*)sender.view];
        [navBar setModalPresentationStyle:UIModalPresentationFormSheet];
        [self.navigationController presentViewController:navBar animated:YES completion:nil];
    }
}

- (void)updateLinesForView:(AYANodeView *)draggableView
{
    for (AYANodeView *node in nodes) {
        for (AYAConnection *connection in node.connectionArray) {
            if ([[connection.lineLayer valueForKeyPath:@"connectionType"] intValue] == kConnectionTypeLine) {
                [CATransaction setDisableActions:YES];
                CALayer *lineLayer = connection.lineLayer;

                CGPoint pos = connection.startView.center;
                CGPoint target = connection.endView.center;
                target.x -= pos.x;
                target.y -= pos.y;
                [self setLayerToLineFromAToB:lineLayer forA:CGPointZero andB:target andLineWidth:8];
                [CATransaction setDisableActions:NO];
            }
        }
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)noteOn:(int)notenumber{
    NSLog(@"Note ON: %d",notenumber);
    [auEngine setNoteOn:notenumber];
}

-(void)noteOff:(int)notenumber{
    NSLog(@"Note OFF: %d",notenumber);
    [auEngine setNoteOff:notenumber];
}




@end
