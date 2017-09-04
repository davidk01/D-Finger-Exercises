import linkedlist;

void LengthTest() {
  auto linked_list = new LinkedList!(uint);
  assert(linked_list.Length == 0, "Empty list should have zero length.");
  linked_list.Insert(1);
  assert(linked_list.Length == 1, "List with one element should have length 1.");
  linked_list.Insert(2);
  linked_list.Insert(3);
  assert(linked_list.Length == 3, "List with three elments should have length 3.");
  linked_list.RemoveNext();
  assert(linked_list.Length == 2, "Removing an element should reduce the length by one.");
  linked_list.RemoveNext();
  assert(linked_list.Length == 1, "Removing two elements should reduce the length by two.");
}

void HeadTailCurrentTest() {
  auto linked_list = new LinkedList!(uint);
  linked_list.Insert(1);
  assert(linked_list.Head.value == 1, "Head element should have value equal to 1.");
  assert(linked_list.Tail.value == 1, "Tail element should have value equal to 1 as well.");
  assert(linked_list.Head == linked_list.Tail, "Head and tail element should be the same when length is 1.");
  assert(linked_list.Current.value == 1, "Current element should have value 1.");
  assert(linked_list.Current == linked_list.Head, "Head and current element should be the same.");
  assert(linked_list.Current == linked_list.Tail, "Tail and current element should be the same.");
  linked_list.Insert(2);
  assert(linked_list.Tail.value == 2, "Tail value should be 2.");
  assert(linked_list.Current == linked_list.Head, "Head and current should still be the same.");
  assert(linked_list.Head.Next == linked_list.Tail, "Head should be linked to tail in a two element list.");
}

void AdvancingTest() {
  auto linked_list = new LinkedList!(uint);
  linked_list.Insert(1);
  assert(linked_list.Current.value == 1, "Current should be pointing at 1.");
  assert(!linked_list.CanAdvance(), "We can not advance in a list with one element.");
  linked_list.Insert(2);
  assert(linked_list.Current.value == 1, "Current should still be pointing at 1.");
  assert(linked_list.CanAdvance(), "We should be able to advance in a list with two elements.");
  linked_list.Advance();
  assert(linked_list.Current.value == 2, "Current should be pointing at 2 after advancing.");
  assert(!linked_list.CanAdvance(), "We can not advance more than once in a list with two elements.");
  assert(linked_list.Current == linked_list.Tail, "Current and tail should be the same element.");
  linked_list.Insert(3);
  assert(linked_list.CanAdvance(), "We just added another element so we should be able to advance.");
  assert(linked_list.Current != linked_list.Tail, "Current should not be pointing at the tail.");
  linked_list.Advance();
  assert(linked_list.Current == linked_list.Tail, "We just advanced so we should be at the tail.");
}

void RewindTest() {
  auto linked_list = new LinkedList!(uint);
  linked_list.Insert(1);
  linked_list.Insert(2);
  linked_list.Insert(3);
  assert(linked_list.Current == linked_list.Head, "We have not moved so we should be at the head.");
  linked_list.Advance();
  assert(linked_list.Current != linked_list.Head, "We have moved so we should not be at the head.");
  assert(linked_list.Current != linked_list.Tail, "We should also not be at the tail.");
  linked_list.Advance();
  assert(linked_list.Current == linked_list.Tail, "We should be at the tail.");
  linked_list.Rewind();
  assert(linked_list.Current == linked_list.Head, "We just rewound so we should be at the head again.");
  assert(linked_list.Tail.value == 2, "Tail value should still be 2.");
}

void main() {
  LengthTest();
  HeadTailCurrentTest();
  AdvancingTest();
  RewindTest();
}
