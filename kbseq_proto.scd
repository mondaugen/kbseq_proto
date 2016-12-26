(
MIDIClient.init;
f={
	var tclk = TempoClock;
	var seq_len = 64;
	var seq_t = 0;
	var m_chan = 0;
	var notes= Array.fill(seq_len,{60});
	var vels = Array.fill(seq_len,{0});
	var lens = Array.fill(seq_len,{4});
	var midi_out = MIDIOut.newByName(
		"SimpleSynth virtual input",
		"SimpleSynth virtual input"
	);
	var t_nofs =Array.fill(128,{-1});
	var add_t_nof = { |note, time|
		if ( t_nofs[note] < time,
			{ t_nofs[note] = time }
		);
	};
	var dec_t_nofs = { |dtime|
		t_nofs = t_nofs.collect({
			|x|
			if (x > 0,
				{
					x = x - dtime;
					if ( x < 0 , {x = 0});
				}
			);
			x
		});
	};
	var do_t_nofs = {
		t_nofs.do({
			|x,i|
			if (x == 0,
				{
					"sending note off".postln;
					midi_out.noteOff(m_chan,i,0);
					t_nofs[i] = -1;
				}
			);
		});
	};
	var do_t_nons = { |time_i|
		if(vels[time_i] > 0 ,
			{
				"sending note on".postln;
				midi_out.noteOn(m_chan,notes[time_i],vels[time_i]);
				add_t_nof.(notes[time_i],lens[time_i]);
			}
		);
	};
	var sched_tick = {
		do_t_nofs.();
		do_t_nons.(seq_t);
		dec_t_nofs.(1);
		seq_t = seq_t + 1;
		if (seq_t >= seq_len,
			{seq_t = 0;}
		);
		1
	};
	~set_beat_note = {
		|beat, note, len = 4, vel = 100|
		notes[beat] = note;
		vels[beat] = vel;
		lens[beat] = len;
	};
	~tclk_start = {
		tclk.sched(0,sched_tick);
		tclk.play();
	};
	~tclk_stop = {
		//tclk.stop();
	};
	~tclk_set_tempo = {
		|tmpo|
		tclk.tempo = tmpo;
	};
};
f.();
)
// ~set_beat_note.(0,64,1);
// ~tclk_start.();
// ~tclk_stop.();
// ~tclk_set_tempo.(40);
// ~set_beat_note.(4,67,60,100);
// 4.do({|x|
// 	~set_beat_note.(4+(x*3),72 - (2*x),1,50)
// });
// 4.do({|x| x.postln});

	