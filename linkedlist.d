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
  
  @property Node Head() {
    return head;
  }
  
  @property Node Tail() {
    return tail;
  }
  
  @property T Current() {
    return current.value;
  }
  
  @property T Current(T new_value) {
    current.value = new_value;
    return new_value;
  }
  
  @property bool CanAdvance() {
    return current.next !is null;
  }
  
  void Rewind() {
    current = head;
  }
  
  void Advance() {
    if (current.next !is null) {
      current = current.next;
    }
  }
  
  void Insert(T element) {
    if (length == 0) {
      head = this.new Node(element);
      tail = head;
      current = head;
    } else {
      auto new_node = this.new Node(element);
      if (current.next is null) {
        current.next = new_node;
        tail = new_node;
      } else {
        auto next_element = current.next;
        current.next = new_node;
        new_node.next = next_element;
      }
    }
    length += 1;
  }
  
  void RemoveNext() {
    if (length > 0 && current.next !is null) {
      auto toLink = current.next.next;
      current.next = toLink;
      if (toLink is null) {
        tail = current;
      }
      length -= 1;
    }
  }
}

//void main() {
//  auto linked_list = new LinkedList!(uint);
//  assert(linked_list.Length == 0, "Empty list has non-zero length.");
//  linked_list.Insert(1);
//  assert(linked_list.Length == 1, "Adding an element did not increase the length of the list.");
//  assert(linked_list.Head.value == 1, "Head element does not have value equal to 1.");
//  assert(linked_list.Tail.value == 1, "Tail element does not have value equal to 1.");
//  assert(linked_list.Current == 1, "Current element is not point at 1.");
//  assert(linked_list.Head is linked_list.Tail, "Head and tail should be the same.");
//  linked_list.Insert(2);
//  assert(linked_list.Tail.value == 2, "Tail value should be 2.");
//  assert(linked_list.Current == 1, "Current element should be 1 since we haven't advanced.");
//  linked_list.Advance();
//  assert(linked_list.Current == 2, "Current element should be 2 because we just advanced.");
//  assert(linked_list.Tail.value == 2, "Tail value is still 2.");
//  linked_list.Insert(3);
//  assert(linked_list.Tail.value == 3, "We just inserted a new value so tail value should be 3.");
//  assert(linked_list.Current == 2, "Current value should be 2 since we haven't advanced.");
//  linked_list.Advance();
//  assert(linked_list.Current == 3, "Current value should be 3 since we just advanced.");
//  linked_list.Rewind();
//  assert(linked_list.Current == linked_list.Head.value, "We just rewound so head and current element must be the same.");
//  linked_list.RemoveNext();
//  assert(linked_list.Length == 2, "We just removed an elemnt so length must be 2.");
//  assert(linked_list.Tail.value == 3, "Tail still points to 3.");
//  assert(linked_list.Head.next is linked_list.Tail, "Head should be pointing at tail.");
//  linked_list.Insert(2);
//  assert(linked_list.Head.next !is linked_list.Tail, "Head should not point to tail anymore.");
//  linked_list.Advance();
//  assert(linked_list.Current == 2, "We just advanced to the second element which should be 2.");
//  linked_list.RemoveNext();
//  assert(linked_list.Tail.value == 2, "Tail should be pointint to 2 since 3 is gone.");
//  assert(linked_list.Head.next is linked_list.Tail, "In a two element list head must point to tail.");
//}
