final class LinkedList(T) {
  private class Node {
    T value;
    Node next;
    
    this() {}

    this(T element) {
      value = element;
    }
  }
  
  private ulong length = 0;
  private Node current;
  private Node head;
  private Node tail;
  
  @property ulong Length() {
    return length;
  }
  
  @property T Head() {
    return head.value;
  }
  
  @property T Tail() {
    return tail.value;
  }
  
  @property T Current() {
    return current.value;
  }
  
  @property T Current(T new_value) {
    current.value = new_value;
    return new_value;
  }
  
  @property bool CanAdvance() {
    return (current.next !is null);
  }
  
  void Advance() {
    if (current.next !is null) {
      current = current.next;
    }
  }
  
  this() {
    current = head;
    tail = head;
  }
  
  void Insert(T element) {
    if (length == 0) {
      head = this.new Node(element);
    } else {
      auto new_node = this.new Node(element);
      if (current.next is null) {
        current.next = new_node;
        tail = new_node;
        current = tail;
      } else {
        auto next_element = current.next;
        current.next = new_node;
        new_node.next = next_element;
        current = new_node;
      }
    }
    length += 1;
  }
  
  void RemoveNext() {
    if (length > 0 && (current.next !is null)) {
      auto toLink = current.next.next;
      current.next = toLink;
      if (toLink is null) {
        tail = current;
      }
      length -= 1;
    }
  }
  
  unittest {
    auto linked_list = new LinkedList!(uint);
    assert(linked_list.Length == 0, "Empty list has non-zero length.");
  }
}
