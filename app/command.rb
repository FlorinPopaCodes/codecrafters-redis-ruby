require "bindata"
class Command < BinData::Record
  endian :little
  uint16 :len
  string :name, read_length: 4
end
