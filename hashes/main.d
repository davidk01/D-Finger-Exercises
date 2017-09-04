import core.stdc.stdlib;
import core.stdc.string;
import core.stdc.stdio;
import core.stdc.math;
import std.traits;
import types;
import tests;

extern (C):

int main() @nogc {
    alias H = HashTable!(char, char, convert, comparison).H;
    auto h = H.make;
    auto k = charify("aa");
    auto kk = charify("bb");
    auto v = charify("cc");
    auto vv = charify("dd");
    printf("sentinel: %x, k: %x, kk: %x, v: %x, vv: %x\n", h.sentinel, k, kk, v, vv);
    printf("inserting k, v\n");
    h.insert(k, v);
    h.dump;
    printf("deleting k\n");
    h.del(k);
    h.dump;
    printf("inserting k, v\n");
    h.insert(k, v);
    h.dump;
    printf("inserting k, vv\n");
    h.insert(k, vv);
    h.dump;
    printf("deleting k\n");
    h.del(k);
    h.dump;
    printf("inserting kk, vv\n");
    h.insert(kk, vv);
    h.dump;
    printf("inserting k, v\n");
    h.insert(k, v);
    h.dump;
    printf("deleting k\n");
    h.del(k);
    h.dump;
    printf("deleting kk\n");
    h.del(kk);
    h.dump;
    printf("inserting v, k, vv, kk, k, v, kk, vv\n");
    h.insert(v, k);
    h.insert(vv, kk);
    h.insert(k, v);
    h.insert(kk, vv);
    h.dump;
    return 0;
}