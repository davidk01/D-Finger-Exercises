import std.stdio;

class LinkedList(T) {
  class Node {
    T value;
    Node next;
    
    this() {}
    this(T element) {
      value = element;
    }
  }
  
  uint length = 1;
  Node current;
  Node head;
  
  this() {
    head = this.new Node;
    current = head;
  }
  
  void Add(T element) {
    auto new_node = this.new Node(element);
    current.next = new_node;
    current = new_node;
    length += 1;
  }
  
  void RemoveNext() {
    auto toLink = current.next.next;
    current.next = toLink;
    length -= 1;
  }
  
  unittest {
    auto list = new LinkedList!(uint);
    assert(list.length == 1, "List length is not 1.");
    assert(list.head.value == 0, "List head value is not 0.");
    list.Add(11);
    assert(list.length == 2, "List length is not 2.");
    assert(list.current.value == 11u, "Current node value is not 11.");
    assert(list.current.next is list.Node.init);
    list.Add(12);
    assert(list.length == 3);
    list.current = list.head;
    list.RemoveNext();
    assert(list.current.next.value == 12, "Remove next did not correctly remove next element.");
  }
}
