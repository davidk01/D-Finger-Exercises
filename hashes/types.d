import core.stdc.stdlib;
import core.stdc.string;
import core.stdc.stdio;
import core.stdc.math;
import std.traits;

extern (C):

/// Two somewhat large primes. Will be used in our hashing function
enum Primes = [393_241, 786_433];

/// When hashing things we expect to be able to convert them to such
/// a struct before operating on them because our hashing function expects
/// a char array and how many elements we expect to find in that array
struct CharLength {
    /// Pointer to a serialized representation of whatever we are hashing
    const char* chars;
    /// Length of the serialized representation
    const size_t length;
    /// When we have the hashed result we pass this struct to this so the memory
    /// can be claned up (if anything was actually allocated that is)
    const void function(CharLength*) @nogc free;
}

/// The things we are trying to hash must be convertible to a format we
/// expect to work with. This template performs that conversion check
template isCharable(K, alias convert) {
    alias T = K*;
    enum bool isCharable = __traits(compiles, (T s) {
        CharLength t = convert(s);
    });
}

/// We need to be able to compare keys so we need some notion of equality.
/// This template performs the check for the equality function signature
template isEquality(K, alias equality) {
    alias T = const(K*);
    enum bool isEquality = __traits(compiles, (T l, T r) {
        bool equal(T l, T r) { return equality(l, r); }
        equal(l, r);
    });
}

/// The hasher works with char array so we expect to be supplied with a conversion
/// function for the types of keys we are working with. The conversion function
/// must give us a struct that can manage the lifetime of the char array. Another
/// way of saying this is that we expect to be able to serialize keys into some
/// kind of finite byte sequence. It is templatized because we want some level of
/// type safety
size_t hasher(K, size_t base, alias convert)(const K* s, const size_t mod) @nogc {
    static assert(base > 0, "base must be positive number");
    static assert(isCharable!(K, convert));
    assert(s !is null);
    assert(mod > 0);
    size_t hash;
    CharLength data = convert(s);
    const length = data.length;
    foreach(size_t index; 0 .. length) {
        hash += pow(base, length - (index + 1)) * data.chars[index];
        hash %= mod;
    }
    // Free any allocations if the conversion function had to allocate
    // memory for the serialization of the key
    data.free(&data);
    return hash;
}

/// Consists of a pair of pointers to a key of type K and a value of type V
struct Item(K, V) {
    // Don't want to repeat Item!(K, V) over and over again
    alias I = Item!(K, V);
    /// The key
    K* key;
    /// The value
    V* value;
    /// Initialize an item
    static I* make(K* k, V* v) @nogc {
        assert(k !is null);
        assert(v !is null);
        auto i = cast(I*)null;
        i = cast(I*)malloc(I.sizeof);
        i.key = k;
        i.value = v;
        return i;
    }
    /// Delete an item
    static void del(ref I* i) @nogc {
        assert(i !is null);
        free(i);
        i = null;
    }
}

/// Hash table that maps keys of type K to values of type V
struct HashTable(K, V, alias convert, alias keyEquality) {
    // Make sure the keys are serializable into a format we expect for hashing
    static assert(isCharable!(K, convert));
    // Make sure we can compare keys for equality
    static assert(isEquality!(K, keyEquality));
    // Don't want to spell out generic types all over the place
    alias I = Item!(K, V);
    alias H = HashTable!(K, V, convert, keyEquality);
    /// Sentinel value to mark deleted items
    I* sentinel;
    /// Current number of entries in the hash table
    size_t count;
    /// Current capacity
    size_t size;
    /// The list of items
    I** items;
    /// Allocate the memory and initialize the entries
    static H* make() @nogc {
        auto h = cast(H*)null;
        h = cast(H*)malloc(H.sizeof);
        h.count = 0;
        h.size = 53;
        h.items = null;
        h.items = cast(I**)calloc(h.size, (I*).sizeof);
        h.sentinel = null;
        h.sentinel = cast(I*)malloc(I.sizeof);
        h.sentinel.key = null;
        h.sentinel.value = null;
        return h;
    }
    /// Print the hash table contents. Useful when debugging
    void dump() @nogc {
        foreach(i; 0 .. size) {
            auto item = items[i];
            if (item !is null) {
                printf("%x: {%x, %x, %x}\n", i, item, item.key, item.value);
            }
        }
    }
    /// Retrieve the item at the given index. Useful during tests
    I* at(size_t index) @nogc {
        if (index >= 0 && index < size) {
            return items[index];
        }
        return null;
    }
    /// Delete the hash table
    static void del(ref H* h) @nogc {
        assert(h !is null);
        assert(h.size > 0);
        assert(h.items !is null);
        foreach(size_t index; 0 .. h.size) {
            auto i = h.items[index];
            if (i !is null) {
                I.del(i);
                h.items[index] = null;
            }
        }
        free(h.items);
        h.items = null;
        free(h);
        h = null;
    }
    /// The hash computation
    size_t hash(const K* k, const size_t attempt) @nogc {
        assert(k !is null);
        assert(attempt >= 0);
        const size_t hashA = hasher!(K, Primes[0], convert)(k, size);
        // You might be curious why I'm using `size - 1` instead of `size`.
        // Good question. Consider what happens `hashB + 1 == k * size` and
        // you'll understand why I'm using `size - 1` instead of `size`.
        const size_t hashB = hasher!(K, Primes[1], convert)(k, size - 1);
        auto h = (hashA + attempt * (hashB + 1)) % size;
        return h;
    }
    /// Find the corresponding item for the given key
    V* search(const K* k) @nogc {
        assert(k !is null);
        size_t attempt;
        auto index = hash(k, attempt);
        auto item = items[index];
        // Q: What happens if all the entries in item table are taken?
        // A: As written this loop will never terminate.
        // TODO: Fix this.
        while (item !is null) {
            if (item !is sentinel && keyEquality(item.key, k)) {
                return item.value;
            }
            attempt++;
            index = hash(k, attempt);
            item = items[index];
        }
        return null;
    }
    /// Insert the key/value pair (k, v) into the hash table
    size_t insert(K* k, V* v) @nogc {
        assert(k !is null);
        assert(v !is null);
        auto item = I.make(k, v);
        size_t attempt;
        auto index = hash(k, attempt);
        auto currentItem = items[index];
        // Q: What happens if all the entries are taken?
        // A: This loop will never terminate.
        // TODO: Fix this.
        while (currentItem !is null && currentItem !is sentinel) {
            if (keyEquality(currentItem.key, k)) {
                I.del(currentItem);
                count--;
                break;
            }
            attempt++;
            index = hash(k, attempt);
            currentItem = items[index];
        }
        items[index] = item;
        count++;
        return index;
    }
    /// Delete the entry corresponding to the given key k
    V* del(const K* k) @nogc {
        assert(k !is null);
        size_t attempt;
        auto index = hash(k, attempt);
        auto item = items[index];
        auto value = item.value;
        // Q: What happens if all the entries are taken?
        // A: This loop will never terminate.
        // TODO: Fix this.
        while (item !is null) {
            value = item.value;
            if (item !is sentinel && keyEquality(item.key, k)) {
                I.del(item);
                count--;
                items[index] = sentinel;
                return value;
            }
            attempt++;
            index = hash(k, attempt);
            item = items[index];
        }
        return value;
    }
}
