import std.stdio;

void main() {
  if (auto a = [1]) {
    writefln("Yes.");
  } else {
    writefln("No.");
  }
}
