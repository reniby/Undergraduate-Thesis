s.boot;


(
~btoD = {
	arg in;
	var mul = 1, res = 0, temp, ns;
	ns = 0.asInteger;
	for (in.size-1, 0, {
		arg i;
		temp = in[i];
		temp = temp.asInteger - ns;
		res = temp*mul + res;
		mul = mul * 2;
	});
	res;
};

~dtoB = {
	arg in, bits;
	in.asInteger.asBinaryDigits(bits);
};

~applyAction = {
	arg action, sp, beats;

	var binS, temp, rand, st;
	var actArr = ['swap', 'combine', 'invert', 'reverse', 'rotate', 'mutate', 'add', 'mul'];

	if(actArr[action] == 'swap', {
		binS = ~dtoB.value(sp, beats*4);
		temp = Array.fill(binS.size, 0);
		for (0, beats-1, {
			arg i;
			temp[0] = binS[2+(i*4)];
			temp[1] = binS[3+(i*4)];
			temp[2] = binS[0+(i*4)];
			temp[3] = binS[1+(i*4)];
		});
		st = ~btoD.value(temp);
	},
	{
		if (actArr[action] == 'combine', {
			binS = ~dtoB.value(sp, beats*4);
			temp = Array.fill(binS.size, 0);
			for (0, beats-1, {
				arg i;
				temp[0] = binS[0+(i*4)];
				temp[1] = binS[2+(i*4)];
				temp[2] = binS[1+(i*4)];
				temp[3] = binS[3+(i*4)];
			});
			st = ~btoD.value(temp);
		},{
			if (actArr[action] == 'invert', {
				binS = ~dtoB.value(sp, beats*4);
				temp = Array.fill(binS.size, 0);
				for (0, beats-1, {
					arg i;
					temp[0+(i*4)] = (binS[0+(i*4)])+1%2;
					temp[1+(i*4)] = (binS[1+(i*4)])+1%2;
					temp[2+(i*4)] = (binS[2+(i*4)])+1%2;
					temp[3+(i*4)] = (binS[3+(i*4)])+1%2;
				});
				st = ~btoD.value(temp);
			}, {
				if (actArr[action] == 'reverse', {
					binS = ~dtoB.value(sp, beats*4);
					temp = Array.fill(binS.size, 0);
					for (0, beats-1, {
						arg i;
						temp[0+(i*4)] = (binS[3+(i*4)]);
						temp[1+(i*4)] = (binS[2+(i*4)]);
						temp[2+(i*4)] = (binS[1+(i*4)]);
						temp[3+(i*4)] = (binS[0+(i*4)]);
					});
					st = ~btoD.value(temp);
				}, {
					if (actArr[action] == 'rotate', {
						binS = ~dtoB.value(sp, beats*4);
						temp = Array.fill(binS.size, 0);
						rand = 4.rand;
						for (0, beats-1, {
							arg i;
							temp[0+(i*4)] = (binS[rand+(i*4)]);
							temp[1+(i*4)] = (binS[(rand+1)%4+(i*4)]);
							temp[2+(i*4)] = (binS[(rand+2)%4+(i*4)]);
							temp[3+(i*4)] = (binS[(rand+3)%4+(i*4)]);
						});
						st = ~btoD.value(temp);
					}, {
						if (actArr[action] == 'mutate', {
							binS = ~dtoB.value(sp, beats*4);
							temp = Array.fill(binS.size, 0);
							rand = 4.rand;
							temp = binS;
							temp[rand] = 1;
							st = ~btoD.value(temp);
						}, {
							if (actArr[action] == 'add', {
								rand = 3.rand +1;
								st = (rand+sp)%16;
							}, {
								if (actArr[action] == 'mul', {
									rand = 3.rand + 1;
									st = (rand*sp)%16;
								}, {});
							});
						});
					});
				});
			});
		});
	});

	st;
};

~main = {
	arg beats;
	var numEvals = 16, ne = 20, lr = 0.1;
	var state = Nil, action = Nil, reward = Nil, sp;
	var actArr = ['swap', 'combine', 'invert', 'reverse', 'rotate', 'mutate', 'add', 'mul'];
	q = Array.fill2D(16**beats, 8, 0);
	n = Array.fill2D(16**beats, 8, 0);


	for (0, 16**beats-1, {
		arg k; //starting beat
		var state = Nil, booltest;
		var rp = 0;

		for (0, 500, {

			var simEnded, fActions, temp, binS, binSp, rand;
			sp = k;
			rp = 0;

			if (state != Nil, {
				n[state][action] = n[state][action] + 1;
				q[state][action] = q[state][action] + lr * (reward + maxItem(q[sp]) - q[state][action]);
			}, {});


			fActions = Array.fill(8,0);

			for (0, 7, {
				arg i;
				if (n[sp][i] < ne, {fActions[i] = 1000000}, {fActions[i] = q[sp][i]});
			});
			state = sp;
			action = maxIndex(fActions);
			reward = rp;

			//action.postln;
			//change state
			sp = ~applyAction.value(action, sp, beats);

			//apply reward
			binS = ~dtoB.value(state, beats*4);
			binSp = ~dtoB.value(sp, beats*4);
			reward = 0;
			temp = [1,0.5,1,0.5];

			for (0, beats-1, {
				arg beat;
				var restP = 0;
				var restC = 0;

				for (0, 3, {
					arg i;
					if (binSp[i+(beat*4)]==binS[i+(beat*4)], {reward = reward + temp[i]}, {});
					if (binSp[i+(beat*4)] == 0, {restP = restP + 1}, {});
					if (binS[i+(beat*4)] == 0, {restC = restC + 1}, {});
				});

				if (reward == 3, {reward = reward - 2}, {});

				if (restP == restC, {reward = reward - 5}, {});
				if (restP > restC, {reward = reward - 5}, {});
				if (restP < restC, {reward = reward + 5}, {});

				if (restP == 4, {reward = reward - 2}, {});
				if (restP == 0, {reward = reward - 1}, {});
			});


		});

	});

	for (0, 16 ** beats - 1, {
		arg k;
		var sp, action;

		action = maxIndex(q[k]);

		sp = ~applyAction.value(action, k, beats);

		~dtoB.value(k, beats*4);//.postln;
		~dtoB.value(sp, beats*4);//.postln;
		//" ".postln;
	});

	q;
};

~main.value(1);
)


(
~toSeq = {
	arg arr, measures;
	var new = Array.fill(4*measures, {0});
	for (0, measures-1, {
		arg i;
		for (0, 3, {
			arg j;
			if (arr[i][j] == 1, {new[i*4 + j] = 1/16;}, {});
			if (arr[i][j] == 0, {new[i*4 + j] = Rest(1/16)}, {});
		});
	});
	new;

};
)
(
~toSeq = {
	arg arr, measures, rest;
	var new = Array.fill(4*measures, {0});
	for (0, measures-1, {
		arg i;
		for (0, 3, {
			arg j;
			var random = 2.rand + 1;
			if (arr[i][j] == 1, {new[i*4 + j] = random/16;}, {});
			if (arr[i][j] == 0, {new[i*4 + j] = Rest(1/16)}, {});
		});
	});
	new;

};
)


(
SynthDef("kick", {arg out = 0, amp = 4, sinfreq = 60, glissf = 0.9, att = 0.01, rel = 0.45, pan = 0;
	var env, snd, ramp;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	ramp = XLine.kr(
		start: sinfreq,
		end: sinfreq * glissf,
		dur: rel
	);
	snd = SinOsc.ar(freq: ramp, mul: env)*10;
	Out.ar(out, snd);
}).add;


SynthDef("hihat", {arg out = 0, amp = 0.1, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
	var env, snd;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = WhiteNoise.ar;
	snd = HPF.ar(in: snd, freq: ffreq, mul: env)*0.6;
	Out.ar(out, Pan2.ar(snd, pan));
}).add;

(
SynthDef(\bass, { |out, freq = 440, gate = 1, amp = 0.05, slideTime = 0.17, ffreq = 1100, width = 0.15,
        detune = 1.005, preamp = 4|
    var sig, env;
	amp = 0.3;
    env = Env.adsr(0.01, 0.3, 0.4, 0.1);
    freq = Lag.kr(freq, slideTime);
    sig = Mix(VarSaw.ar([freq, freq * detune], 0, width, preamp)).distort * amp
        * EnvGen.kr(env, gate, doneAction: Done.freeSelf);
    sig = LPF.ar(sig, ffreq);
    Out.ar(out, sig ! 2)
}).add;
)
)

(
~translate = {
	arg start, measures;
	var end = Array.fill2D(measures, 4, {0});
	var next;
	var act;

	~main.value(1);


	for (0, measures-1, {

		arg i;
		act = maxIndex(q[~btoD.value(start[i])]);
		next = ~applyAction.value(act, ~btoD.value(start[i]), 1);
		next = ~dtoB.value(next, 4);
		end[i] = next;
	});
	//"BEFORE: " + start.postln;
	//"AFTER: " + end.postln;
	end;
};
~play = {
	arg start, instr;
	var curr, next;
	curr = Pbind(
		\instrument, instr,
		\dur, Pseq(start, inf),
		\att, 0.01,
		\rel, 0.22,
		\midinote, Pseq([24.rand+36, 24.rand+36, 24.rand+36, 24.rand+36, 24.rand+36, 24.rand+36, 24.rand+36, 24.rand+36], inf),
		\sinfreq, 60,
		\glissf, 0.9,
		\tempo, 0.5
	);
	curr;
};

FreqScope.new(400, 200, 0, server: s);

)
