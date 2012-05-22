final class LinkedList(T) {
  private class Node {
    T value;
    private Node next;
    
    this() {}

    this(T element) {
      value = element;
    }
    
    @property Node Next() {
      return next;
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
  
  @property Node Current() {
    return current;
  }
  
  @property Node Current(T new_value) {
    current.value = new_value;
    return current;
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
      head = new Node(element);
      tail = head;
      current = head;
    } else {
      auto new_node = new Node(element);
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
