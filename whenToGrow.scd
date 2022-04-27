s.boot;

//first, initialize each fxn in howToGrow (no need to edit it)

//the start arrays can be edited to change the starting beats
//put the name of the desired beat into the p array like this
//p = [[section1_instrument1, section1_instrument2], [section2_instrument1, section2_instrument2]
//pl is the player, set p1 = p[idx][#].play to play the correctly indexed Pbind
//there are a number of threshold values that can all be changed (freqThreshold=200, ampThreshold=0.5, timeThreshold = 3, sumThreshold = 200)
//use freq.poll(); and amp.poll(); in ~triggerSynth to find the right values for your instrument (generaly, the minimum value of each variable in higher intensity section)
    //ampSum can be associated with the total reward printed, again use the minimum total reward printed when playing with high intensity




(
var measures = 8;
var start = Array.fill2D(measures, 4, {0});
var p1=0, p2=0, k1=0, k2=0, h1=0, h2=0;
var kick, hi, bass;

//bass drum, set each beat below (currently, 8 beats- if changing change "measures" above too
start[0] = [1,0,0,0];
start[1] = [1,0,0,0];
start[2] = [1,0,0,0];
start[3] = [1,0,0,0];
start[4] = [1,0,0,0];
start[5] = [1,0,0,0];
start[6] = [1,0,0,0];
start[7] = [1,0,0,0];
k1 = ~play.value(~toSeq.value(start, measures), "kick");
k2 = ~translate.value(start, measures);
k2 = ~play.value(~toSeq.value(k2, measures, 0), "kick");


//hihat
start[0] = [1,0,0,0];
start[1] = [1,0,0,0];
start[2] = [1,0,0,0];
start[3] = [1,0,0,0];
start[4] = [1,0,0,0];
start[5] = [1,0,0,0];
start[6] = [1,0,0,0];
start[7] = [1,0,0,0];
h1 = ~play.value(~toSeq.value(start, measures), "kick");
h2 = ~translate.value(start, measures);
h2 = ~play.value(~toSeq.value(h2, measures, 0), "kick");

//bass
start[0] = [1,0,0,0];
start[1] = [0,0,0,0];
start[2] = [1,0,0,1];
start[3] = [0,0,0,0];
start[4] = [1,0,1,0];
start[5] = [0,0,0,0];
start[6] = [1,0,0,1];
start[7] = [1,1,0,0];
p1 = ~play.value(~toSeq.value(start, measures), "bass");
p2 = ~translate.value(start, measures);
p2 = ~play.value(~toSeq.value(p2, measures), "bass");

p = [[h1, p1], [h2, p2]];
)

(
var fsum = 0;
var asum = 0;
var pl = Array.fill(p.size, 0);
var currCount = 0;
var idx = 0;
pl = p[idx][1].play; //create more players for mutiple instruments, using the p array as shown here

~checkSwitch = {
	arg on;


	if (on==1, {currCount = currCount + 1;}, {currCount = currCount - 1;});
	if (currCount < 0, {currCount = 0}, {});
	if (currCount > 2,
		{if (idx < (p[idx].size-1), {
		idx = idx + 1;
		pl.stop;
		pl = p[idx][1].play;},{}

	)});

	currCount.postln;
};

z = Date.getDate.rawSeconds;
y = z;

~triggerSynth = SynthDef(\triggerSynth, { |inbus, thresh = 0.8, decay = 1| //set threshold and decay
	var freqThreshold=200, ampThreshold=0.5; //threshold knobs
    var    amp = Amplitude.kr(In.ar(inbus, 1), attackTime: 0.01, releaseTime: decay);
	var freq = 0, hasFreq = 0;
	# freq, hasFreq = Pitch.kr(In.ar(inbus, 1));

        // this trigger gets sent only when amplitude crosses threshold
	SendReply.kr(((hasFreq>0)*(freq>freqThreshold)*(amp>ampThreshold)), '/upTrig');
}).play(args: [inbus: s.options.numOutputBusChannels, thresh: ~threshView.value, decay: ~decayView.value]);
​
~triggerResp = OSCFunc({ |msg|
	var curr = Date.getDate.rawSeconds;
	var timeThreshold = 3, sumThreshold = 200; //time frame (seconds) before input data gets reset
	if ((curr-y) > timeThreshold, {y = Date.getDate.rawSeconds;
		"total score".postln;
		asum.postln;
		if (asum > 200, {~checkSwitch.value(1)}, { ~checkSwitch.value(0)}); //"200" may need to change for different instrumental inputs
		asum = 0;
	}, {asum = asum + 1;} //0.7
	);
}, '/upTrig', s.addr);


)

