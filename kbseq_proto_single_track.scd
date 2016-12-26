(
MIDIClient.init;
f={
	var tclk = TempoClock;
	var seq_len = 64;
	var seq_t = 0;
	var m_chan = 0;
	var notes = Array.fill(seq_len,{List.new;});
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
					//"sending note off".postln;
					midi_out.noteOff(m_chan,i,0);
					t_nofs[i] = -1;
				}
			);
		});
	};
	var do_t_nons = { |time_i|
		notes[time_i].do({ |x|
			//"sending note on".postln;
			midi_out.noteOn(m_chan,x["pch"],x["vel"]);
			add_t_nof.(x["pch"],x["dur"]);
		});
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
	~rm_note = {
		|beat,pch|
		notes[beat].removeAllSuchThat({|x| x["pch"] == pch });
	};
	~add_note = {
		|beat, pch, dur = 4, vel = 100|
		var note = Dictionary.new;
		~rm_note.(beat,pch);
		note["pch"] = pch;
		note["vel"] = vel;
		note["dur"] = dur;
		notes[beat].add(note);
		notes[beat].sort({|a,b| a["pch"] > b["pch"]});
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
~add_note.(0,68);
~add_note.(0,62,32,60);
~tclk_start.();