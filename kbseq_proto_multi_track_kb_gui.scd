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
	var regs = Dictionary.newFrom([\seqs,Dictionary.new,\trks,Dictionary.new]);
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
	var win = Window.new("test arguments");
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
	var t_cur = 0;
	var big_t_cur = 0, mid_t_cur = 0, sma_t_cur = 0;
	var n_cur = 60;
	var n_pc = 0, n_oct = 0;
	var big_l_cur = 0, mid_l_cur = 0, sma_l_cur = 0;
	var l_cur = 4;
	var trk_cur = 0;
	var vel_cur = 100;
	var num_q = String.new(8);
	var calc_t_cur = {
		t_cur = ((big_t_cur * seq_len * 0.25)
		+ (mid_t_cur * seq_len * 0.25/4.0)
			+ (sma_t_cur * seq_len * 0.25 / 16.0)).round.asInteger;
		"t_cur: ".post; t_cur.postln;
		win.refresh;
	};
	var calc_l_cur = {
		l_cur = ((big_l_cur * seq_len * 0.25)
		+ (mid_l_cur * seq_len * 0.25/4.0)
			+ (sma_l_cur * seq_len * 0.25 / 16.0)).round.asInteger;
		"l_cur: ".post; l_cur.postln;
		win.refresh;
	};
	var calc_n_cur = {
		n_cur = (n_oct * 12) + n_pc + 60;
		"n_cur: ".post; n_cur.postln;
		win.refresh;
	};

	~rm_note = {
		|track,beat,pch|
		notes[track][beat].removeAllSuchThat({|x| x["pch"] == pch });
		win.refresh;
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
		win.refresh;

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
		regs[\seqs][reg]=notes.deepCopy;
	};
	~recall_seq = {
		|reg|
		if (regs[\seqs][reg].isNil.not,
			{notes = regs[\seqs][reg].deepCopy;});
		win.refresh;
	};
	~store_trk = {
		|reg|
		regs[\trks][reg]=notes[trk_cur].deepCopy;
	};
	~recall_trk = {
		|reg|
		if (regs[\trks][reg].isNil.not,
			{notes[trk_cur] = regs[\trks][reg].deepCopy;});
		win.refresh;
	};
	~paste_trk = {
		|reg,time,pch,pch_ofst=60|
		if (regs[\trks][reg].isNil.not,
			{
				seq_len.do({
					|t|
					var note_list = regs[\trks][reg][t];
					if (note_list.size > 0, {
						note_list.do({
							|note|
							var note_tmp = note.deepCopy;
							note_tmp["pch"] = note_tmp["pch"] - pch_ofst + pch;
							notes[trk_cur][(time + t).mod(seq_len)].add(note_tmp);
							notes[trk_cur][(time + t).mod(seq_len)].sort({|a,b| a["pch"] > b["pch"]});
						});
					});
				});
		});
	};
	~clear_seq = {
		notes = Array.fill(n_tracks, { Array.fill(seq_len,{List.new;}); });
		win.refresh;
	};
	~clear_trk = {
		notes[trk_cur] = Array.fill(seq_len,{List.new;});
		win.refresh;
	};
	~save_regs = {
		|path|
		regs.writeArchive(path);
	};
	~load_regs = {
		|path|
		regs = Object.readArchive(path);
	};
	win.view.keyDownAction = { |doc, char, mod, unicode, keycode, key|
		    [doc, char, mod, unicode, keycode, key].postln;
		switch(unicode,

			// Time cursor

			113,{ big_t_cur = 0; calc_t_cur.() }, // q
			119,{ big_t_cur = 1; calc_t_cur.() },  // w
			101,{ big_t_cur = 2; calc_t_cur.() },  // e
			114,{ big_t_cur = 3; calc_t_cur.() },  // r

			97,{ mid_t_cur = 0; calc_t_cur.() },  // a
			115,{ mid_t_cur = 1; calc_t_cur.() }, // s
			100,{ mid_t_cur = 2; calc_t_cur.() }, // d
			102,{ mid_t_cur = 3; calc_t_cur.() }, // f

			122,{ sma_t_cur = 0; calc_t_cur.() }, // z
			120,{ sma_t_cur = 1; calc_t_cur.() }, // x
			99,{ sma_t_cur = 2; calc_t_cur.() }, // c
			118,{ sma_t_cur = 3; calc_t_cur.() }, // v

			// Length cursor

			81,{ big_l_cur = 0; calc_l_cur.() }, // Q
			87,{ big_l_cur = 1; calc_l_cur.() },  // W
			69,{ big_l_cur = 2; calc_l_cur.() },  // E
			82,{ big_l_cur = 3; calc_l_cur.() },  // R

			65,{ mid_l_cur = 0; calc_l_cur.() },  // A
			83,{ mid_l_cur = 1; calc_l_cur.() }, // S
			68,{ mid_l_cur = 2; calc_l_cur.() }, // D
			70,{ mid_l_cur = 3; calc_l_cur.() }, // F

			90,{ sma_l_cur = 0; calc_l_cur.() }, // Z
			88,{ sma_l_cur = 1; calc_l_cur.() }, // X
			67,{ sma_l_cur = 2; calc_l_cur.() }, // C
			86,{ sma_l_cur = 3; calc_l_cur.() }, // V

			// Note cursor

			98, { n_pc = 0; calc_n_cur.(); }, // b , C
			110, { n_pc = 7; calc_n_cur.(); }, // n, G
			103, { n_pc = 2; calc_n_cur.(); }, // g, D
			104, { n_pc = 9; calc_n_cur.(); }, // h, A
			116, { n_pc = 4; calc_n_cur.(); }, // t, E
			121, { n_pc = 11; calc_n_cur.(); }, // y, B
			117, { n_oct = n_oct + 1; calc_n_cur.(); }, // u, +8ve

			66, { n_pc = 6; calc_n_cur.(); }, // B, F#
			78,  { n_pc = 1; calc_n_cur.(); },// N, C#
			71, { n_pc = 8; calc_n_cur.(); }, // G, G#
			72, { n_pc = 3; calc_n_cur.(); }, // H, Eb
			84, { n_pc = 10; calc_n_cur.(); }, // T, Bb
			89, { n_pc = 5; calc_n_cur.(); }, // Y, F
			85, { n_oct = n_oct - 1; calc_n_cur.(); }, // U, -8ve

			// Escape key, resets number agument queue

			27, { num_q = ""; },

			// Number arguments

			48, {num_q = num_q ++ "0"; }, // 0
			49, {num_q = num_q ++ "1"; },
			50, {num_q = num_q ++ "2"; },
			51, {num_q = num_q ++ "3"; },
			52, {num_q = num_q ++ "4"; },
			53, {num_q = num_q ++ "5"; },
			54, {num_q = num_q ++ "6"; },
			55, {num_q = num_q ++ "7"; },
			56, {num_q = num_q ++ "8"; },
			57, {num_q = num_q ++ "9"; }, // 9

			// Test number argument

			107, {
/*					~add_note = {
		|track,beat, pch, dur = 4, vel = 100|*/
				~add_note.(trk_cur, t_cur, n_cur, l_cur, vel_cur);
			}, // k

			// Set track
			106, { // j
				if (num_q.size > 0, {
					var trk;
					trk = num_q.asInteger;
					num_q = "";
					if ((trk >= 0).and(trk < n_tracks),
						{ trk_cur = trk});
					"trk_cur: ".post; trk_cur.postln;
				});
			},

			// Set velocity
			108, { // l
				if(num_q.size > 0, {
					var vel;
					vel = num_q.asInteger;
					num_q = "";
					if ((vel > 0).and(vel < 128),
						{ vel_cur = vel});
					"vel_cur: ".post; vel_cur.postln;
				});
			},

/*				~rm_note = {
		|track,beat,pch|*/
			92, { // \
				"removing note".postln;
				~rm_note.(trk_cur, t_cur, n_cur);
				// remove note
			},

			124, { // |
				"clearing sequence".postln;
				~clear_seq.();
			},

			34, { // "
				"clearing track".postln;
				~clear_trk.();
			},

			105, { // i
				var regnum = num_q.asInteger;
				num_q = "";
				"storing sequence.".postln;
				~store_seq.(regnum);
			},

			73, { // I
				var regnum = num_q.asInteger;
				num_q = "";
				"recalling sequence.".postln;
				~recall_seq.(regnum);
			},

			111, { // o
				var regnum = num_q.asInteger;
				num_q = "";
				"storing track.".postln;
				~store_trk.(regnum);
			},

			79, { // O
				var regnum = num_q.asInteger;
				num_q = "";
				"recalling track.".postln;
				~recall_trk.(regnum);
			},

			112, { // p , paste track
				var regnum = num_q.asInteger;
				num_q = "";
				"pasting track".postln;
/*					~paste_trk = {
		|reg,time,pch,pch_ofst=60|*/
				~paste_trk.(regnum,t_cur,n_cur);
			},

//			"unknown key".postln;
		);
		win.refresh;
	};
	win.drawFunc = {
		var ofst_x = 10;
		var ofst_y = 10;

		// Draw track backgrounds
		n_tracks.do({
			|i|
			if (i == trk_cur,{
				Pen.color = Color.grey(0.75);
			},{
				Pen.color = Color.grey(0.5);
			});
			Pen.addRect(
				Rect(ofst_x, ofst_y + (i * 12), seq_len * 4, 12);
			);
			Pen.addArc((ofst_x+(seq_len *4))@(ofst_y + (i * 12) + 6),6,3.0/2.0 * pi, pi );
			Pen.perform(\fill);

		});

		// Draw cursor
		Pen.color = Color.magenta(1,0.5);
		Pen.addRect(
			Rect(ofst_x + (t_cur * 4), ofst_y + (trk_cur * 12) + n_cur.mod(12),  l_cur * 4, 1);
		);
		Pen.perform(\fill);

		// Draw notes
		notes.do({
			|x,trk|
			x.do({
				|y,beat|
				y.do({
					|z|

					Pen.color = Color.black(1,0.5);
					Pen.addRect(
						Rect(ofst_x + (beat * 4), ofst_y + (trk * 12) + z["pch"].mod(12),  z["dur"] * 4, 1);
					);
					Pen.perform(\fill);
				});
			});
		});

		// Draw playhead
		Pen.color = Color.red(1,0.5);
		Pen.line(Point(ofst_x + (seq_t * 4),0),Point(ofst_x + (seq_t * 4), ofst_y + (16 *12)));
		Pen.stroke;

	};
	AppClock.sched(0,{
		win.refresh;
		0.1;
	});
	win.front;
};
f.();
)
~save_regs.("/tmp/a");
~load_regs.("/tmp/a");
~tclk_start.();
~tclk_set_tempo.(10);
10.do({|i| i.postln; });