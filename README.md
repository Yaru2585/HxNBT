**HxNBT: A NBT parser for Haxe**
--------------------------------

  HxNBT is a small library that allows you to write, parse and convert Named Binary Tag (or NBT) files, mainly used by the game Minecraft.
  You can read a specification of the NBT format [here](http://wiki.vg/NBT).

***(Warning: This is still a WIP, and there's some things to correct:***

 ***- Parsing of Tag_List(Compound) isn't supported yet.***
 
 ***If you can help with any of these things, please submit a Pull Request.)***

## Usage ##
*(You can see an example of usage in Main.hx)*

**Writing**

Init a new instance of the writer.

    var nbt:NbtWriter = new NbtWriter();

Every NBT file must start with a TAG_Compound:

    nbt.writeCompound("root")
    
   Then, you can write any kind of fields you like...
   

    nbt.writeString("test", "Hello world");		
    nbt.writeByte("byte test", 10);
    nbt.writeByteArray("array test", Bytes.ofString("AAAAA"));
    nbt.writeFloat("float test", 12.5);
    nbt.writeInt("int test", 6);
    nbt.writeIntArray("array int", [1, 2, 3, 4]);
    nbt.writeShort("short test", 3);
    nbt.writeString("second string", "Goodbye");
    nbt.writeLong("long test", "9223372036854775807");

Or other compounds inside the first one!

    nbt.writeCompound("lists");
    nbt.writeByteList("byteList", [1, 2, 3, 4, 5]);
    nbt.writeByteArrayList("byteArrayList", [Bytes.ofString("AAAAA"), Bytes.ofString("BBBBB")]);
    nbt.writeShortList("shortList", [1, 2, 3]);
    nbt.writeIntList("intList", [1, 2, 3]);
    nbt.writeFloatList("floatList", [1.34, 2.45, 3.12]);
    nbt.writeIntArrayList("intArrayList", [[1, 2, 3], [3, 4, 1]]);
    nbt.writeDoubleList("doubleList", [12.4, 304.2, 232.4]);
    nbt.writeLongList("longList", ["9223372036854775807", "9223372036854775807", "9223372036854775807"]);
	nbt.writeEnd(); //Closing "Lists"
Once you're finished, close the root compound...

    nbt.writeEnd(); //Closing "root"
And then you can save the result to a file...

    nbt.closeAndSave("test.nbt") //You can compress it!
Or just get the data

    nbt.getOutput(); //Raw data
    nbt.getCompressedOutput(); //Compressed with GZIP.
	

**Parsing**

First get the NBT data:

    var fin:FileInput = File.read("test.nbt",true);
Then give it to the parser...

    var parser:NbtParser = new NbtParser(fin,true,"test.json",false); //In order: FileInput, BigEndian, OutputName, Compressed.

And that's it! If you write an output name, the result will be exported as a Json file. If you don't, you can get the data with `getObjectAsString()` or `getObjectAsJson()`

## Dependencies ##
[OpenFL](lib.haxe.org/p/openfl/4.1.0/) (3,5,2 or higher, used for GZIP compression)

[Lime](lib.haxe.org/p/lime/3.1.0/) (2,8,1 or higher, as above)

[Thx.Core](lib.haxe.org/p/thx.core/versions) (0,40,1 or higher, used for writing and parsing of Int64s until the latest version of Haxe gets out of development)
