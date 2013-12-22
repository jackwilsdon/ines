
class INES
  # Header size (16 bytes)
  INES_HEADER_SIZE = 0x10

  # Trainer size (512 bytes)
  INES_TRAINER_SIZE = 0x200

  # Program (PRG) ROM size (16384 bytes)
  INES_PRG_PAGE_SIZE = 0x4000

  # Character (CHR) ROM size (8192 bytes)
  INES_CHR_PAGE_SIZE = 0x2000

  # The ROM, stored as an array of bytes
  bytes = []

  # Create an INES instance with an optional file to load
  def initialize(filename = nil)
    unless filename.nil?
      load(filename)
    end
  end

  # Load a file, replacing all data previously loaded
  def load(filename)
    unless File.file? filename
      raise "file not found: #{filename}"
    end

    file = File.new(filename, 'r')
    @bytes = file.read.unpack 'C*'
    file.close

    return nil
  end

  # Save the current data to file
  def save(filename, overwrite = false)
    if File.file?(filename) && !overwrite
      raise "file exists: #{filename}"
    end

    file = File.new(filename, 'wb')
    file.write @bytes.pack('C*')
    file.close

    return nil
  end

  # Write data to the ROM at the defined offset
  def write(offset, data, enlarge = false)
    if (offset + data.length) > @bytes.length && !enlarge
      raise 'writing past the end of the rom'
    end

    data.length.times { @bytes.delete_at offset }

    for i in 0 ... data.length
      @bytes.insert(offset + i, data[i])
    end

    return nil
  end

  # Calculate the data offset, excluding header and trainer (if applicable)
  def offset
    return INES_HEADER_SIZE + ((self.trainer?) ? INES_TRAINER_SIZE : 0)
  end

  # Get the iNES header as an array of bytes
  def header
    if @bytes.length < INES_HEADER_SIZE
      raise 'invalid or missing header'
    end

    return @bytes.slice(0, INES_HEADER_SIZE)
  end

  # Check whether the ROM has a trainer
  def trainer?
    return ((self.header[6] & 0xF) & 4) > 0
  end

  # Retrieve the trainer from the ROM, if one is available
  def trainer
    if self.trainer?
      if (self.offset + INES_TRAINER_SIZE) > @bytes.length
        raise 'invalid trainer'
      end

      return @bytes.slice(self.offset, INES_TRAINER_SIZE)
    end

    return nil
  end

  # Calculate the program data (PRG) offset from the start of the file
  def prg_offset
    return self.offset
  end

  # Calculate the size of the program data (PRG)
  def prg_size
    return self.header[4] * INES_PRG_PAGE_SIZE
  end

  # Retrieve the program data (PRG) from the ROM
  def prg
    if (self.prg_offset + self.prg_size) > @bytes.length
      raise 'invalid prg'
    end

    return @bytes.slice(self.prg_offset, self.prg_size)
  end

  # Calculate the character (CHR) offset from the start of the file
  def chr_offset
    return self.offset + self.prg_size
  end

  # Calculate the size of the character data (CHR)
  def chr_size
    return self.header[5] * INES_CHR_PAGE_SIZE
  end

  # Retrieve the character data (CHR) from the ROM
  def chr
    if (self.chr_offset + self.chr_size) > @bytes.length
      raise 'invalid chr'
    end

    return @bytes.slice(self.chr_offset, self.chr_size)
  end
end
