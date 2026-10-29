#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""zlib10_deflate.py -- the deflate of zlib 1.0.4, the version linked into the KN7000 / KN6000
programs (banner "deflate 1.0.4 Copyright 1995-1996 Jean-loup Gailly", program 941 file
0x3B8604), in pure Python, so that the floppies' .AST files can be rebuilt from their images.

Why a port: a modern zlib (1.2.x / 1.3.x, which Python links) does not produce the same bytes.
1.0.4's _tr_tally ends a block early when, every 4096 symbols, its estimate says the block
compresses well (the "Try to guess if it is profitable to stop the current block here" test;
later versions compile it only with TRUNCATE_BLOCK), so its block boundaries differ.  Measured
2026-10-29: Python's zlib 1.3.1 at the same settings differs from 01CUSTM1.AST at byte 1, and
the zlib 1.0.4 C sources (zlib.net/fossils/zlib-1.0.4.tar.gz) reproduce it exactly, and this port
reproduces all ten .AST files of idd7000 / custom1 / custom2 / idd6000 (make verify-customdata-ast;
kn7000/notes/custom-data-ic21-probes/README.md).

This file transcribes deflate.c (lm_init, fill_window, longest_match without UNALIGNED_OK,
deflate_slow) and trees.c (_tr_tally, _tr_flush_block, build_tree, gen_bitlen, gen_codes,
scan_tree / send_tree, build_bl_tree, compress_block, _tr_stored_block) of 1.0.4, with the
64 KB sliding window, the hash slide and the Freq/Code and Dad/Len unions of ct_data kept, so
it follows the C step for step.  Only deflate_slow (levels 4..9) is ported; the input is taken
in one piece with Z_FINISH, which gives the same stream as any chunking without flushes.

  deflate_raw(data, level=6, mem_level=8) -> the raw deflate stream (no zlib header/trailer)
  python3 zlib10_deflate.py IN OUT          write the raw stream of file IN
"""
import sys

MIN_MATCH, MAX_MATCH = 3, 258
MIN_LOOKAHEAD = MAX_MATCH + MIN_MATCH + 1
TOO_FAR = 4096
LENGTH_CODES, LITERALS = 29, 256
L_CODES = LITERALS + 1 + LENGTH_CODES
D_CODES, BL_CODES = 30, 19
HEAP_SIZE = 2 * L_CODES + 1
MAX_BITS, MAX_BL_BITS = 15, 7
END_BLOCK, REP_3_6, REPZ_3_10, REPZ_11_138 = 256, 16, 17, 18
STORED_BLOCK, STATIC_TREES, DYN_TREES = 0, 1, 2

EXTRA_LBITS = [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0]
EXTRA_DBITS = [0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13]
EXTRA_BLBITS = [0] * 16 + [2, 3, 7]
BL_ORDER = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15]
# good, lazy, nice, chain (configuration_table; 4..9 use deflate_slow)
CONFIG = {4: (4, 4, 16, 16), 5: (8, 16, 32, 32), 6: (8, 16, 128, 128), 7: (8, 32, 128, 256),
          8: (32, 128, 258, 1024), 9: (32, 258, 258, 4096)}


def bi_reverse(code, length):
    res = 0
    for _ in range(length):
        res = (res << 1) | (code & 1)
        code >>= 1
    return res


class Tree:
    """ct_data[]: fc = the Freq/Code union, dl = the Dad/Len union."""
    def __init__(self, n):
        self.fc = [0] * n
        self.dl = [0] * n


def gen_codes(tree, max_code, bl_count):
    next_code = [0] * (MAX_BITS + 1)
    code = 0
    for bits in range(1, MAX_BITS + 1):
        code = ((code + bl_count[bits - 1]) << 1) & 0xFFFF
        next_code[bits] = code
    for n in range(max_code + 1):
        ln = tree.dl[n]
        if ln == 0:
            continue
        tree.fc[n] = bi_reverse(next_code[ln], ln)
        next_code[ln] += 1


# tr_static_init
LENGTH_CODE = [0] * 256
BASE_LENGTH = [0] * LENGTH_CODES
DIST_CODE = [0] * 512
BASE_DIST = [0] * D_CODES


def _static_init():
    length = 0
    code = 0
    for code in range(LENGTH_CODES - 1):
        BASE_LENGTH[code] = length
        for _ in range(1 << EXTRA_LBITS[code]):
            LENGTH_CODE[length] = code
            length += 1
    # length 255 (match length 258) takes code 285, not 284 + 5 bits: in the C the loop
    # variable is LENGTH_CODES-1 here
    LENGTH_CODE[length - 1] = LENGTH_CODES - 1
    dist = 0
    for code in range(16):
        BASE_DIST[code] = dist
        for _ in range(1 << EXTRA_DBITS[code]):
            DIST_CODE[dist] = code
            dist += 1
    dist >>= 7
    for code in range(16, D_CODES):
        BASE_DIST[code] = dist << 7
        for _ in range(1 << (EXTRA_DBITS[code] - 7)):
            DIST_CODE[256 + dist] = code
            dist += 1
    st = Tree(L_CODES + 2)
    bl_count = [0] * (MAX_BITS + 1)
    for n in range(288):
        ln = 8 if n <= 143 else 9 if n <= 255 else 7 if n <= 279 else 8
        st.dl[n] = ln
        bl_count[ln] += 1
    gen_codes(st, L_CODES + 1, bl_count)
    sd = Tree(D_CODES)
    for n in range(D_CODES):
        sd.dl[n] = 5
        sd.fc[n] = bi_reverse(n, 5)
    return st, sd


STATIC_LTREE, STATIC_DTREE = _static_init()


def d_code(dist):
    return DIST_CODE[dist] if dist < 256 else DIST_CODE[256 + (dist >> 7)]


class StatDesc:
    def __init__(self, static_tree, extra, base, elems, max_length):
        self.static_tree, self.extra, self.base, self.elems, self.max_length = \
            static_tree, extra, base, elems, max_length


STATIC_L_DESC = StatDesc(STATIC_LTREE, EXTRA_LBITS, LITERALS + 1, L_CODES, MAX_BITS)
STATIC_D_DESC = StatDesc(STATIC_DTREE, EXTRA_DBITS, 0, D_CODES, MAX_BITS)
STATIC_BL_DESC = StatDesc(None, EXTRA_BLBITS, 0, BL_CODES, MAX_BL_BITS)


class Desc:
    def __init__(self, tree, stat):
        self.dyn_tree, self.stat_desc, self.max_code = tree, stat, 0


class Deflate:
    def __init__(self, data, level=6, mem_level=8, w_bits=15):
        self.data, self.next_in = data, 0
        self.level = level
        self.w_bits = w_bits
        self.w_size = 1 << w_bits
        self.w_mask = self.w_size - 1
        self.hash_bits = mem_level + 7
        self.hash_size = 1 << self.hash_bits
        self.hash_mask = self.hash_size - 1
        self.hash_shift = (self.hash_bits + MIN_MATCH - 1) // MIN_MATCH
        self.window = bytearray(self.w_size * 2)       # zcalloc: zeroed
        self.prev = [0] * self.w_size
        self.head = [0] * self.hash_size
        self.lit_bufsize = 1 << (mem_level + 6)
        self.d_buf = [0] * self.lit_bufsize
        self.l_buf = [0] * self.lit_bufsize
        self.max_dist = self.w_size - MIN_LOOKAHEAD
        # bit output
        self.out = bytearray()
        self.bi_buf = 0
        self.bi_valid = 0
        # _tr_init
        self.dyn_ltree = Tree(HEAP_SIZE)
        self.dyn_dtree = Tree(2 * D_CODES + 1)
        self.bl_tree = Tree(2 * BL_CODES + 1)
        self.l_desc = Desc(self.dyn_ltree, STATIC_L_DESC)
        self.d_desc = Desc(self.dyn_dtree, STATIC_D_DESC)
        self.bl_desc = Desc(self.bl_tree, STATIC_BL_DESC)
        self.heap = [0] * (2 * L_CODES + 1)
        self.depth = [0] * (2 * L_CODES + 1)
        self.bl_count = [0] * (MAX_BITS + 1)
        self.init_block()
        # lm_init
        self.window_size = 2 * self.w_size
        good, lazy, nice, chain = CONFIG[level]
        self.max_lazy_match, self.good_match, self.nice_match, self.max_chain_length = lazy, good, nice, chain
        self.strstart = 0
        self.block_start = 0
        self.lookahead = 0
        self.match_length = self.prev_length = MIN_MATCH - 1
        self.match_available = 0
        self.match_start = 0
        self.prev_match = 0
        self.ins_h = 0

    # ---- bit output (send_bits / bi_windup: LSB first, the same bytes as the 16-bit buffer)
    def send_bits(self, value, length):
        self.bi_buf |= value << self.bi_valid
        self.bi_valid += length
        while self.bi_valid >= 8:
            self.out.append(self.bi_buf & 0xFF)
            self.bi_buf >>= 8
            self.bi_valid -= 8

    def bi_windup(self):
        if self.bi_valid > 0:
            self.out.append(self.bi_buf & 0xFF)
        self.bi_buf = 0
        self.bi_valid = 0

    # ---- trees.c
    def init_block(self):
        for n in range(L_CODES):
            self.dyn_ltree.fc[n] = 0
        for n in range(D_CODES):
            self.dyn_dtree.fc[n] = 0
        for n in range(BL_CODES):
            self.bl_tree.fc[n] = 0
        self.dyn_ltree.fc[END_BLOCK] = 1
        self.opt_len = self.static_len = 0
        self.last_lit = self.matches = 0

    def smaller(self, tree, n, m):
        return tree.fc[n] < tree.fc[m] or (tree.fc[n] == tree.fc[m] and self.depth[n] <= self.depth[m])

    def pqdownheap(self, tree, k):
        heap = self.heap
        v = heap[k]
        j = k << 1
        while j <= self.heap_len:
            if j < self.heap_len and self.smaller(tree, heap[j + 1], heap[j]):
                j += 1
            if self.smaller(tree, v, heap[j]):
                break
            heap[k] = heap[j]
            k = j
            j <<= 1
        heap[k] = v

    def gen_bitlen(self, desc):
        tree, max_code = desc.dyn_tree, desc.max_code
        st = desc.stat_desc
        stree, extra, base, max_length = st.static_tree, st.extra, st.base, st.max_length
        heap = self.heap
        bl_count = self.bl_count
        for b in range(MAX_BITS + 1):
            bl_count[b] = 0
        overflow = 0
        tree.dl[heap[self.heap_max]] = 0
        h = self.heap_max + 1
        while h < HEAP_SIZE:
            n = heap[h]
            bits = tree.dl[tree.dl[n]] + 1
            if bits > max_length:
                bits = max_length
                overflow += 1
            tree.dl[n] = bits
            h += 1
            if n > max_code:
                continue
            bl_count[bits] += 1
            xbits = extra[n - base] if n >= base else 0
            f = tree.fc[n]
            self.opt_len += f * (bits + xbits)
            if stree:
                self.static_len += f * (stree.dl[n] + xbits)
        if overflow == 0:
            return
        while True:
            bits = max_length - 1
            while bl_count[bits] == 0:
                bits -= 1
            bl_count[bits] -= 1
            bl_count[bits + 1] += 2
            bl_count[max_length] -= 1
            overflow -= 2
            if overflow <= 0:
                break
        h = HEAP_SIZE
        for bits in range(max_length, 0, -1):
            n = bl_count[bits]
            while n != 0:
                h -= 1
                m = heap[h]
                if m > max_code:
                    continue
                if tree.dl[m] != bits:
                    self.opt_len += (bits - tree.dl[m]) * tree.fc[m]
                    tree.dl[m] = bits
                n -= 1

    def build_tree(self, desc):
        tree = desc.dyn_tree
        stree = desc.stat_desc.static_tree
        elems = desc.stat_desc.elems
        heap, depth = self.heap, self.depth
        max_code = -1
        self.heap_len, self.heap_max = 0, HEAP_SIZE
        for n in range(elems):
            if tree.fc[n] != 0:
                self.heap_len += 1
                heap[self.heap_len] = max_code = n
                depth[n] = 0
            else:
                tree.dl[n] = 0
        while self.heap_len < 2:
            if max_code < 2:
                max_code += 1
                node = max_code
            else:
                node = 0
            self.heap_len += 1
            heap[self.heap_len] = node
            tree.fc[node] = 1
            depth[node] = 0
            self.opt_len -= 1
            if stree:
                self.static_len -= stree.dl[node]
        desc.max_code = max_code
        for n in range(self.heap_len // 2, 0, -1):
            self.pqdownheap(tree, n)
        node = elems
        while True:
            # pqremove
            n = heap[1]
            heap[1] = heap[self.heap_len]
            self.heap_len -= 1
            self.pqdownheap(tree, 1)
            m = heap[1]
            self.heap_max -= 1
            heap[self.heap_max] = n
            self.heap_max -= 1
            heap[self.heap_max] = m
            tree.fc[node] = tree.fc[n] + tree.fc[m]
            depth[node] = (max(depth[n], depth[m]) + 1) & 0xFF
            tree.dl[n] = tree.dl[m] = node
            heap[1] = node
            node += 1
            self.pqdownheap(tree, 1)
            if self.heap_len < 2:
                break
        self.heap_max -= 1
        heap[self.heap_max] = heap[1]
        self.gen_bitlen(desc)
        gen_codes(tree, max_code, self.bl_count)

    def scan_tree(self, tree, max_code):
        prevlen, nextlen, count = -1, tree.dl[0], 0
        max_count, min_count = 7, 4
        if nextlen == 0:
            max_count, min_count = 138, 3
        tree.dl[max_code + 1] = 0xFFFF
        bl = self.bl_tree.fc
        for n in range(max_code + 1):
            curlen, nextlen = nextlen, tree.dl[n + 1]
            count += 1
            if count < max_count and curlen == nextlen:
                continue
            elif count < min_count:
                bl[curlen] += count
            elif curlen != 0:
                if curlen != prevlen:
                    bl[curlen] += 1
                bl[REP_3_6] += 1
            elif count <= 10:
                bl[REPZ_3_10] += 1
            else:
                bl[REPZ_11_138] += 1
            count, prevlen = 0, curlen
            if nextlen == 0:
                max_count, min_count = 138, 3
            elif curlen == nextlen:
                max_count, min_count = 6, 3
            else:
                max_count, min_count = 7, 4

    def send_code(self, c, tree):
        self.send_bits(tree.fc[c], tree.dl[c])

    def send_tree(self, tree, max_code):
        prevlen, nextlen, count = -1, tree.dl[0], 0
        max_count, min_count = 7, 4
        if nextlen == 0:
            max_count, min_count = 138, 3
        bl = self.bl_tree
        for n in range(max_code + 1):
            curlen, nextlen = nextlen, tree.dl[n + 1]
            count += 1
            if count < max_count and curlen == nextlen:
                continue
            elif count < min_count:
                while True:
                    self.send_code(curlen, bl)
                    count -= 1
                    if count == 0:
                        break
            elif curlen != 0:
                if curlen != prevlen:
                    self.send_code(curlen, bl)
                    count -= 1
                self.send_code(REP_3_6, bl)
                self.send_bits(count - 3, 2)
            elif count <= 10:
                self.send_code(REPZ_3_10, bl)
                self.send_bits(count - 3, 3)
            else:
                self.send_code(REPZ_11_138, bl)
                self.send_bits(count - 11, 7)
            count, prevlen = 0, curlen
            if nextlen == 0:
                max_count, min_count = 138, 3
            elif curlen == nextlen:
                max_count, min_count = 6, 3
            else:
                max_count, min_count = 7, 4

    def build_bl_tree(self):
        self.scan_tree(self.dyn_ltree, self.l_desc.max_code)
        self.scan_tree(self.dyn_dtree, self.d_desc.max_code)
        self.build_tree(self.bl_desc)
        max_blindex = BL_CODES - 1
        while max_blindex >= 3:
            if self.bl_tree.dl[BL_ORDER[max_blindex]] != 0:
                break
            max_blindex -= 1
        self.opt_len += 3 * (max_blindex + 1) + 5 + 5 + 4
        return max_blindex

    def send_all_trees(self, lcodes, dcodes, blcodes):
        self.send_bits(lcodes - 257, 5)
        self.send_bits(dcodes - 1, 5)
        self.send_bits(blcodes - 4, 4)
        for rank in range(blcodes):
            self.send_bits(self.bl_tree.dl[BL_ORDER[rank]], 3)
        self.send_tree(self.dyn_ltree, lcodes - 1)
        self.send_tree(self.dyn_dtree, dcodes - 1)

    def compress_block(self, ltree, dtree):
        for lx in range(self.last_lit):
            dist, lc = self.d_buf[lx], self.l_buf[lx]
            if dist == 0:
                self.send_code(lc, ltree)
            else:
                code = LENGTH_CODE[lc]
                self.send_code(code + LITERALS + 1, ltree)
                extra = EXTRA_LBITS[code]
                if extra:
                    self.send_bits(lc - BASE_LENGTH[code], extra)
                dist -= 1
                code = d_code(dist)
                self.send_code(code, dtree)
                extra = EXTRA_DBITS[code]
                if extra:
                    self.send_bits(dist - BASE_DIST[code], extra)
        self.send_code(END_BLOCK, ltree)

    def tr_stored_block(self, buf, stored_len, eof):
        self.send_bits((STORED_BLOCK << 1) + eof, 3)
        self.bi_windup()
        self.out += bytes([stored_len & 0xFF, (stored_len >> 8) & 0xFF,
                           ~stored_len & 0xFF, (~stored_len >> 8) & 0xFF])
        self.out += buf

    def tr_flush_block(self, buf, stored_len, eof):
        self.build_tree(self.l_desc)
        self.build_tree(self.d_desc)
        max_blindex = self.build_bl_tree()
        opt_lenb = (self.opt_len + 3 + 7) >> 3
        static_lenb = (self.static_len + 3 + 7) >> 3
        if static_lenb <= opt_lenb:
            opt_lenb = static_lenb
        if stored_len + 4 <= opt_lenb and buf is not None:
            self.tr_stored_block(buf, stored_len, eof)
        elif static_lenb == opt_lenb:
            self.send_bits((STATIC_TREES << 1) + eof, 3)
            self.compress_block(STATIC_LTREE, STATIC_DTREE)
        else:
            self.send_bits((DYN_TREES << 1) + eof, 3)
            self.send_all_trees(self.l_desc.max_code + 1, self.d_desc.max_code + 1, max_blindex + 1)
            self.compress_block(self.dyn_ltree, self.dyn_dtree)
        self.init_block()
        if eof:
            self.bi_windup()

    def tr_tally(self, dist, lc):
        self.d_buf[self.last_lit] = dist
        self.l_buf[self.last_lit] = lc
        self.last_lit += 1
        if dist == 0:
            self.dyn_ltree.fc[lc] += 1
        else:
            self.matches += 1
            dist -= 1
            self.dyn_ltree.fc[LENGTH_CODE[lc] + LITERALS + 1] += 1
            self.dyn_dtree.fc[d_code(dist)] += 1
        # 1.0.4: "Try to guess if it is profitable to stop the current block here"
        if self.level > 2 and (self.last_lit & 0xFFF) == 0:
            out_length = self.last_lit * 8
            in_length = self.strstart - self.block_start
            for dcode in range(D_CODES):
                out_length += self.dyn_dtree.fc[dcode] * (5 + EXTRA_DBITS[dcode])
            out_length >>= 3
            if self.matches < self.last_lit // 2 and out_length < in_length // 2:
                return 1
        return self.last_lit == self.lit_bufsize - 1

    def flush_block(self, eof):
        if self.block_start >= 0:
            buf = bytes(self.window[self.block_start:self.strstart])
        else:
            buf = None
        self.tr_flush_block(buf, self.strstart - self.block_start, eof)
        self.block_start = self.strstart

    # ---- deflate.c
    def fill_window(self):
        wsize = self.w_size
        while True:
            more = self.window_size - self.lookahead - self.strstart
            if self.strstart >= wsize + self.max_dist:
                self.window[0:wsize] = self.window[wsize:2 * wsize]
                self.match_start -= wsize
                self.strstart -= wsize
                self.block_start -= wsize
                self.head = [m - wsize if m >= wsize else 0 for m in self.head]
                self.prev = [m - wsize if m >= wsize else 0 for m in self.prev]
                more += wsize
            avail = len(self.data) - self.next_in
            if avail == 0:
                return
            n = min(avail, more)
            p = self.strstart + self.lookahead
            self.window[p:p + n] = self.data[self.next_in:self.next_in + n]
            self.next_in += n
            self.lookahead += n
            if self.lookahead >= MIN_MATCH:
                self.ins_h = self.window[self.strstart]
                self.ins_h = ((self.ins_h << self.hash_shift) ^ self.window[self.strstart + 1]) & self.hash_mask
            if not (self.lookahead < MIN_LOOKAHEAD and self.next_in < len(self.data)):
                return

    def longest_match(self, cur_match):
        w = self.window
        chain_length = self.max_chain_length
        strstart = self.strstart
        best_len = self.prev_length
        nice_match = self.nice_match
        limit = strstart - self.max_dist if strstart > self.max_dist else 0
        prev, wmask = self.prev, self.w_mask
        scan_end1, scan_end = w[strstart + best_len - 1], w[strstart + best_len]
        s0, s1 = w[strstart], w[strstart + 1]
        tail = bytes(w[strstart + 3:strstart + MAX_MATCH])
        if self.prev_length >= self.good_match:
            chain_length >>= 2
        if nice_match > self.lookahead:
            nice_match = self.lookahead
        while True:
            m = cur_match
            if not (w[m + best_len] != scan_end or w[m + best_len - 1] != scan_end1 or
                    w[m] != s0 or w[m + 1] != s1):
                other = w[m + 3:m + MAX_MATCH]
                if other == tail:
                    ln = MAX_MATCH
                else:
                    k = 0
                    while tail[k] == other[k]:
                        k += 1
                    ln = 3 + k
                if ln > best_len:
                    self.match_start = cur_match
                    best_len = ln
                    if ln >= nice_match:
                        break
                    scan_end1, scan_end = w[strstart + best_len - 1], w[strstart + best_len]
            cur_match = prev[cur_match & wmask]
            if cur_match <= limit:
                break
            chain_length -= 1
            if chain_length == 0:
                break
        return best_len if best_len <= self.lookahead else self.lookahead

    def deflate_slow(self):
        hash_head = 0
        w = self.window
        while True:
            if self.lookahead < MIN_LOOKAHEAD:
                self.fill_window()
                w = self.window
                if self.lookahead == 0:
                    break
            if self.lookahead >= MIN_MATCH:
                self.ins_h = ((self.ins_h << self.hash_shift) ^ w[self.strstart + 2]) & self.hash_mask
                hash_head = self.head[self.ins_h]
                self.prev[self.strstart & self.w_mask] = hash_head
                self.head[self.ins_h] = self.strstart
            self.prev_length, self.prev_match = self.match_length, self.match_start
            self.match_length = MIN_MATCH - 1
            if (hash_head != 0 and self.prev_length < self.max_lazy_match and
                    self.strstart - hash_head <= self.max_dist):
                self.match_length = self.longest_match(hash_head)
                if self.match_length <= 5 and (self.match_length == MIN_MATCH and
                                               self.strstart - self.match_start > TOO_FAR):
                    self.match_length = MIN_MATCH - 1
            if self.prev_length >= MIN_MATCH and self.match_length <= self.prev_length:
                max_insert = self.strstart + self.lookahead - MIN_MATCH
                bflush = self.tr_tally(self.strstart - 1 - self.prev_match, self.prev_length - MIN_MATCH)
                self.lookahead -= self.prev_length - 1
                self.prev_length -= 2
                head, prv, wmask, shift, hmask = self.head, self.prev, self.w_mask, self.hash_shift, self.hash_mask
                h = self.ins_h
                s = self.strstart
                while True:
                    s += 1
                    if s <= max_insert:
                        h = ((h << shift) ^ w[s + 2]) & hmask
                        hash_head = head[h]
                        prv[s & wmask] = hash_head
                        head[h] = s
                    self.prev_length -= 1
                    if self.prev_length == 0:
                        break
                self.ins_h = h
                self.strstart = s
                self.match_available = 0
                self.match_length = MIN_MATCH - 1
                self.strstart += 1
                if bflush:
                    self.flush_block(0)
            elif self.match_available:
                if self.tr_tally(0, w[self.strstart - 1]):
                    self.flush_block(0)
                self.strstart += 1
                self.lookahead -= 1
            else:
                self.match_available = 1
                self.strstart += 1
                self.lookahead -= 1
        if self.match_available:
            self.tr_tally(0, w[self.strstart - 1])
            self.match_available = 0
        self.flush_block(1)
        return bytes(self.out)


def deflate_raw(data, level=6, mem_level=8):
    if level not in CONFIG:
        raise ValueError("only levels 4..9 (deflate_slow) are ported")
    return Deflate(bytes(data), level, mem_level).deflate_slow()


if __name__ == "__main__":
    src, dst = sys.argv[1:3]
    open(dst, "wb").write(deflate_raw(open(src, "rb").read()))
