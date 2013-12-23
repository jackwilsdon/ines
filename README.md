# iNES ROM format for Ruby #
Manipulate iNES ROM files and extract trainer, PRG and CHR roms!

## Example usage ##
```ruby
require 'ines'

def save_prg(ines, name)
  prg = ines.prg

  File.open(name, 'wb') do |file|
    file.write(prg.pack('C*'))
  end
end

def save_chr(ines, name)
  chr = ines.chr

  File.open(name, 'wb') do |file|
    file.write(chr.pack('C*'))
  end
end

ines = INES.new 'mario.nes'

save_prg(ines, 'mario.prg')
save_chr(ines, 'mario.chr')
```
