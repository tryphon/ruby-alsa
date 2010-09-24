class Integer 

  def to_pointer
    pointer = MemoryPointer.new(:int)
    pointer.write_int(self)

    unless block_given?
      pointer
    else
      begin
        return yield pointer
      ensure
        pointer.free
      end
    end
  end

end

class Array 

  def to_pointers
    pointers = map(&:to_pointer)
    unless block_given?
      pointers
    else
      begin
        return yield pointers
      ensure
        pointers.each(&:free)
      end
    end
  end

end
