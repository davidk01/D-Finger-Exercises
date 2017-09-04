final class DoublyLinkedList(T) {
  private class Node {
    T value;
    private Node next;
    private Node previous;
    
    this(in T element) {
      value = element;
    }
    
    @property Node Next() {
      return next;
    }
    
    @property Node Previous() {
      return previous;
    }
  }
  
  private ulong length;
  private Node head;
  private Node current;
  
  @property ulong Length() {
    return length;
  }
  
  @property Node Head() {
    return head;
  }
  
  @property Node Current() {
    return current;
  }
  
  void Rewind() {
    current = head;
  }
  
  bool Advance() {
    if (length == 0 || current.next is null) {
      return false;
    }
    current = current.next;
    return true;
  }
  
  bool Retreat() {
    if (length == 0 || current.previous is null) {
      return false;
    }
    current = current.previous;
    return true;
  }
  
  void Insert(in T element) {
    auto new_node = new Node(element);
    if (length == 0) {
      head = new_node;
      current = head;
    } else {
      auto nxt = current.next;
      new_node.previous = current;
      new_node.next = nxt;
      current.next = new_node;
      if (nxt !is null) {
        nxt.previous = new_node;
      }
    }
    length++;
  }
  
  bool RemoveNext() {
    if (length > 0 && current.next !is null) {
      auto to_link = current.next.next;
      current.next = to_link;
      if (to_link !is null) {
        to_link.previous = current;
      }
      length--;
      return true;
    }
    return false;
  }
}
