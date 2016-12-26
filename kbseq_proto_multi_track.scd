(
MIDIClient.init;
f={
	var tclk = TempoClock;
	var seq_len = 64;
	var seq_t = 0;
	var m_chan = 0;
	var n_tracks = 16;
	var n_chans = 16;
	var chan_map = [0,1,2,3,4,5,6,9,7,8,10,11,12,13,14,15]; // Drum channel on 8th track
	var notes = Array.fill(n_tracks, { Array.fill(seq_len,{List.new;}); });
	var seq_regs = Dictionary.new;
	var midi_out = MIDIOut.newByName(
		"SimpleSynth virtual input",
		"SimpleSynth virtual input"
	);
	// Done this way because multiple tracks could send on the same channel
	var t_nofs = Array.fill( n_chans, { Array.fill(128,{-1}); });
	var add_t_nof = { |chan, note, time|
		if ( t_nofs[chan][note] < time,
			{ t_nofs[chan][note] = time }
		);
	};
	var dec_t_nofs = { |dtime|
		t_nofs = t_nofs.collect({
			|ls|
			ls = ls.collect({
				|x|
				if (x > 0,
					{
						x = x - dtime;
						if ( x < 0 , {x = 0});
					}
				);
				x
			});
			ls
		});
	};
	var do_t_nofs = {
		t_nofs.do({
			|ls,chn|
			ls.do({
				|x,i|
				if (x == 0,
					{
						//"sending note off".postln;
						midi_out.noteOff(chn,i,0);
						t_nofs[chn][i] = -1;
					}
				);
			});
		});
	};
	var do_t_nons = { |time_i|
		notes.do({
			|trk,trk_n|
			trk[time_i].do({ |x|
				//"sending note on".postln;
				midi_out.noteOn(chan_map[trk_n],x["pch"],x["vel"]);
				add_t_nof.(chan_map[trk_n],x["pch"],x["dur"]);
			});
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
		|track,beat,pch|
		notes[track][beat].removeAllSuchThat({|x| x["pch"] == pch });
	};
	~add_note = {
		|track,beat, pch, dur = 4, vel = 100|
		var note = Dictionary.new;
		~rm_note.(track,beat,pch);
		note["pch"] = pch;
		note["vel"] = vel;
		note["dur"] = dur;
		notes[track][beat].add(note);
		notes[track][beat].sort({|a,b| a["pch"] > b["pch"]});
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
	~store_seq = {
		|reg|
		seq_regs[reg]=notes;
	};
	~recall_seq = {
		|reg|
		if (seq_regs[reg].isNil.not,
			{notes = seq_regs[reg];});
	};
	~clear_seq = {
		notes = Array.fill(n_tracks, { Array.fill(seq_len,{List.new;}); });
	};
	~save_seqs = {
		|path|
		seq_regs.writeArchive(path);
	};
	~load_seqs = {
		|path|
		seq_regs = Object.readArchive(path);
	};
};
f.();
)

(
~add_note.(0,0,60);
~add_note.(1,5,67);
~store_seq.(1);
)
(
~add_note.(0,0,50);
~add_note.(7,5,40);
~store_seq.(2);
)
~clear_seq.();
~tclk_start.();
~tclk_set_tempo.(25);
~save_seqs.("/tmp/a");
~load_seqs.("/tmp/a");
~recall_seq.(2);

