import std.stdio: readln, writeln, writef;
import std.array: split;

struct Sdaux {
	int[9][324] r;
	int[4][729] c;

	void initialize() {
		int r1 = 0;
		for (int i = 0; i < 9; ++i)
			for (int j = 0; j < 9; ++j)
				for (int k = 0; k < 9; ++k)
					c[r1++][] = [9 * i + j, (i/3*3 + j/3) * 9 + k + 81, 9 * i + k + 162, 9 * j + k + 243];
		byte[324] nr;
		for (int r2 = 0; r2 < 729; ++r2)
			for (int c2 = 0; c2 < 4; ++c2) {
				auto k = c[r2][c2];
				r[k][nr[k]++] = r2;
			}
	}
}

int sdUpdate(in Sdaux *aux, byte *sr, ubyte *sc, in int r, in int v)
{
	int min = 10, min_c;
	for (size_t c2 = 0; c2 < 4; ++c2) sc[aux.c[r][c2]] += v << 7;
	for (size_t c2 = 0; c2 < 4; ++c2) {
		int c = aux.c[r][c2], rr;
		if (v > 0) {
			for (size_t r2 = 0; r2 < 9; ++r2) {
				if (sr[rr = aux.r[c][r2]]++ != 0) continue;
				for (size_t cc2 = 0; cc2 < 4; ++cc2) {
					int cc = aux.c[rr][cc2];
					if (--sc[cc] < min)
						min = sc[cc], min_c = cc;
				}
			}
		} else {
			for (size_t r2 = 0; r2 < 9; ++r2) {
				if (--sr[rr = aux.r[c][r2]] != 0) continue;
				auto p = aux.c[rr].ptr;
				++sc[p[0]]; ++sc[p[1]]; ++sc[p[2]]; ++sc[p[3]];
			}
		}
	}
	return min << 16 | min_c;
}

int sdSolve(in Sdaux *aux, in char *_s)
{
	int hints;
	byte[729] sr;
	byte[81] cr = -1;
	ubyte[324] sc = 9;
	short[81] cc = -1;
	char[81] outs;

	for (int i = 0; i < 81; ++i) {
		int a = _s[i] >= '1' && _s[i] <= '9'? _s[i] - '1' : -1;
		if (a >= 0) sdUpdate(aux, sr.ptr, sc.ptr, i * 9 + a, 1);
		if (a >= 0) ++hints;
		outs[i] = _s[i];
	}

	int dir, i, r, cand, n, min;
	for (i = 0, dir = 1, cand = 10 << 16 | 0;;) {
		while (i >= 0 && i < 81 - hints) {
			if (dir == 1) {
				min = cand >> 16, cc[i] = cast(short)(cand & 0xFFFF);
				if (min > 1) {
					for (size_t c = 0; c < sc.length; ++c) {
						if (sc[c] < min) {
							min = sc[c], cc[i] = cast(short)c;
							if (min <= 1) break;
						}
					}
				}
				if (min == 0 || min == 10) dir = cr[i--] = -1;
			}
			int r2, c = cc[i];
			if (dir == -1 && cr[i] >= 0) sdUpdate(aux, sr.ptr, sc.ptr, aux.r[c][cr[i]], -1);
			for (r2 = cr[i] + 1; r2 < 9; ++r2)
				if (sr[aux.r[c][r2]] == 0) break;
			if (r2 < 9) {
				cand = sdUpdate(aux, sr.ptr, sc.ptr, aux.r[c][r2], 1);
				cr[i++] = cast(byte)r2; dir = 1;
			} else dir = cr[i--] = -1;
		}
		if (i < 0) break;
		for (size_t j = 0; j < i; ++j) {
			r = aux.r[cc[j]][cr[j]];
			outs[r / 9] = cast(char)(r % 9 + '1'); // print
		}
		writeln(outs);
		++n; --i; dir = -1;
	}
	return n;
}

const string hard20 =
`..............3.85..1.2.......5.7.....4...1...9.......5......73..2.1........4...9
.......12........3..23..4....18....5.6..7.8.......9.....85.....9...4.5..47...6...
.2..5.7..4..1....68....3...2....8..3.4..2.5.....6...1...2.9.....9......57.4...9..
........3..1..56...9..4..7......9.5.7.......8.5.4.2....8..2..9...35..1..6........
12.3....435....1....4........54..2..6...7.........8.9...31..5.......9.7.....6...8
1.......2.9.4...5...6...7...5.9.3.......7.......85..4.7.....6...3...9.8...2.....1
.......39.....1..5..3.5.8....8.9...6.7...2...1..4.......9.8..5..2....6..4..7.....
12.3.....4.....3....3.5......42..5......8...9.6...5.7...15..2......9..6......7..8
..3..6.8....1..2......7...4..9..8.6..3..4...1.7.2.....3....5.....5...6..98.....5.
1.......9..67...2..8....4......75.3...5..2....6.3......9....8..6...4...1..25...6.
..9...4...7.3...2.8...6...71..8....6....1..7.....56...3....5..1.4.....9...2...7..
....9..5..1.....3...23..7....45...7.8.....2.......64...9..1.....8..6......54....7
4...3.......6..8..........1....5..9..8....6...7.2........1.27..5.3....4.9........
7.8...3.....2.1...5.........4.....263...8.......1...9..9.6....4....7.5...........
3.7.4...........918........4.....7.....16.......25..........38..9....5...2.6.....
........8..3...4...9..2..6.....79.......612...6.5.2.7...8...5...1.....2.4.5.....3
.......1.4.........2...........5.4.7..8...3....1.9....3..4..2...5.1........8.6...
.......12....35......6...7.7.....3.....4..8..1...........12.....8.....4..5....6..
1.......2.9.4...5...6...7...5.3.4.......6........58.4...2...6...3...9.8.7.......1
.....1.2.3...4.5.....6....7..2.....1.8..9..3.4.....8..5....2....9..3.4....67.....`;

void main() {
	int n = 100;
	Sdaux a;
	a.initialize();
	auto b = hard20.split("\n");
	for (int i = 0; i < n; ++i) {
		foreach (ref str; b) {
			if (str.length < 81) continue;
			sdSolve(&a, str.ptr);
			writef("\n");
		}
	}
}
