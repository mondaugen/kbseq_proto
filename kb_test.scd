(
f = {
	var win = Window.new("test arguments");
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
		t_cur = (big_t_cur * 0.25) + (mid_t_cur * 0.25/4.0) + (sma_t_cur * 0.25 / 16.0);
		"t_cur: ".post; t_cur.postln;
	};
	var calc_l_cur = {
		l_cur = (big_l_cur * 0.25) + (mid_l_cur * 0.25/4.0) + (sma_l_cur * 0.25 / 16.0);
		"l_cur: ".post; l_cur.postln;
	};
	var calc_n_cur = {
		n_cur = (n_oct * 12) + n_pc + 60;
		"n_cur: ".post; n_cur.postln;
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

			107, {num_q.asInteger.postln; }, // k

			// Set track
			106, { // j
				if (num_q.size > 0, {trk_cur = num_q.asInteger});
				"trk_cur: ".post; trk_cur.postln;
			},

			// Set velocity
			108, { // l
				if(num_q.size > 0, {vel_cur = num_q.asInteger});
				"vel_cur: ".post; vel_cur.postln;
			},

			92, { // \
				"removing note".postln;
				// remove note
			}
//			"unknown key".postln;
		);
	};
	win.front;
};
f.();
)

s = String.new(8);
s = s = s ++ "4";
s = s.clear;
s = String.new(8);
s.asInteger
	s.size.postln
	s= "";

		10.mod(5);