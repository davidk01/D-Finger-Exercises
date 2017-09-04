import core.stdc.stdio;
import core.stdc.string;
import core.stdc.stdlib;
import types;

extern (C):

/// Take a string and convert it to char*
char* charify(string str) @nogc {
    auto arr = cast(char*)malloc(str.length + 1);
    foreach(i; 0 .. str.length) {
        arr[i] = str[i];
    }
    arr[str.length] = '\0';
    return arr;
}

/// No-op because we let the caller deal with managing the lifetime of keys.
/// If we were dealing with actual serialization of keys then this would not
/// be a no-op.
/// Todo: Implement this for a type that requires non-trivial memory management
void charFree(const CharLength* i) @nogc {
    return;
}

/// Converted format expected by the hashing function
CharLength convert(const char* s) @nogc {
    return CharLength(s, strlen(s), &charFree);
}

/// If same pointers then nothing to do otherwise call strcmp.
/// Todo: Is there a more generic way to write this function?
bool comparison(const char* l, const char* r) @nogc {
    return l is r || strcmp(l, r) == 0;
}

unittest {
    // Avoid repeating ourselves
    alias H = HashTable!(char, char, convert, comparison).H;
    auto h = H.make;
    // Some keys and values
    auto k = charify("aa");
    auto kk = charify("bb");
    auto v = charify("cc");
    auto vv = charify("dd");
    auto count = h.count;
    /// Sentinel value sanity checks
    assert(h.sentinel !is null, "sentinel value must not be null");
    assert(h.sentinel.key is null, "sentinel key must be null");
    assert(h.sentinel.value is null, "sentinel value must be null");
    /// Inserting k/v pair increases the count
    auto index = h.insert(k, v);
    count++;
    assert(h.count == count, "count must be incremented after k/v insertion");
    /// We can get back the value we inserted by searching
    assert(h.search(k) is v, "we must get back the same value that we inserted");
    /// We can also retrieve the value by indexing
    assert(h.at(index).value is v, "we can index and grab the value");
    assert(h.at(index).key is k, "the key at the given index must match inserted k/v pair key");
    /// When we delete we get back what we inserted and count is decremented
    auto deleted = h.del(k);
    count--;
    assert(deleted is v, "when deleting we get back the value as a result");
    assert(h.count == count, "after deleting the count must be decremented");
    /// We can't recovered deleted k/v pairs and the item becomes a sentinel
    assert(h.search(k) is null, "looking for a deleted key returns a null result");
    assert(h.at(index) is h.sentinel, "deleted items become sentinels");
    /// Reinserting same k/v pair gives us the same item index
    auto newIndex = h.insert(k, v);
    count++;
    assert(index == newIndex, "item insertion index is stable across insertions");
    /// Count must have gone up after insertion
    assert(h.count == 1, "after inserting a key count must have been incremented");
    /// Overwriting an entry with the same key keeps count the same
    auto overwrittenIndex = h.insert(k, vv);
    assert(h.count == count, "overriding a key must not change the count");
    assert(h.search(k) is vv, "we must get back the overriden value");
    assert(index == overwrittenIndex && newIndex == overwrittenIndex, "indices must still match");
    /// Deleting must decrement the count and returned value must match
    deleted = h.del(k);
    count--;
    assert(h.count == count, "deleting decrements the count");
    assert(vv is deleted, "deleted value must match overriden value");
    assert(h.at(index) is h.sentinel, "deleted entry is a sentinel");
    /// Inserting another key increases the count and places it at new index
    auto newKeyIndex = h.insert(kk, vv);
    count++;
    assert(h.count == count, "inserting key must increment count");
    assert(newKeyIndex != index, "different keys must map to different indices");
    assert(h.at(newKeyIndex).key is kk, "we can recover the key by index");
    assert(h.at(newKeyIndex).value is vv, "we can recover the value by index");
    assert(h.search(kk) is vv, "we can recover the value by searching");
    /// Reinserting an old key increments the count and is idempotent
    index = h.insert(k, v);
    count++;
    assert(h.count == count, "inserting k/v pair increments the count");
    assert(index == h.insert(k, v), "insertion is idempotent");
    assert(h.count == count, "count did not change when we inserted same key");
    /// Count should decrease when we delete
    deleted = h.del(k);
    count--;
    assert(deleted is v, "deleted value must match the key");
    assert(h.count == count, "count decreased when we deleted");
    assert(h.del(k) is null && h.count == count, "deleting the same key does not change anything");
    /// Count should decrease again when we delete another key
    deleted = h.del(kk);
    count--;
    assert(deleted is vv, "deleted value must match the key we deleted");
    assert(h.count == count, "count must have decreased");
    assert(h.del(kk) is null && h.count == count, "deleting same key twice is idempotent");
    /// When we insert 4 keys the count must go up accordingly
    auto indexV = h.insert(v, k);
    assert(h.at(indexV).key is v);
    assert(h.at(indexV).value is k);
    count++;
    auto indexVV = h.insert(vv, kk);
    assert(h.at(indexVV).key is vv);
    assert(h.at(indexVV).value is kk);
    count++;
    auto indexK = h.insert(k, v);
    assert(h.at(indexK).key is k);
    assert(h.at(indexK).value is v);
    count++;
    auto indexKK = h.insert(kk, vv);
    assert(h.at(indexKK).key is kk);
    assert(h.at(indexKK).value is vv);
    count++;
    assert(count == 4 && h.count == count, "count must be 4 after inserting 4 k/v pairs");
}