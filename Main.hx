package;

import com.github.yarukatsaros.hxnbt.NbtParser;
import com.github.yarukatsaros.hxnbt.NbtTag;
import com.github.yarukatsaros.hxnbt.NbtWriter;
import haxe.io.Bytes;
import openfl.utils.ByteArray;
import sys.io.File;

/**
 * ...
 * @author Yaru
 */
class Main 
{
	
	static function main() 
	{
		/**
		 * EXAMPLES: Uncomment and compile.
		 */
		
		//writeNBTFile(); //Example of writing a nbt file (test.nbt)
		//readNBTFile(); //Example of parsing a nbt file and exporting to a .json
		//readNBTData(); //Example of parsing nbt data from getOutput()
		//readCompressedNBTData(); //Example of parsing compressed nbt data from getCompressedOutput()
	}
	
	static private function writeNBTFile():Void 
	{
		var nbt:NbtWriter = new NbtWriter();
		nbt.writeCompound("root");
		
		nbt.writeString("test", "Hello world \\s38f");		
		nbt.writeByte("byte test", 10);
		nbt.writeByteArray("array test", Bytes.ofString("AAAAA"));
		nbt.writeFloat("float test", 12.5);
		nbt.writeInt("int test", 6);
		nbt.writeIntArray("array int", [1, 2, 3, 4]);
		nbt.writeShort("short test", 3);
		nbt.writeString("second string", "Goodbye");
		nbt.writeLong("long test", "9223372036854775807");
	
		
		//FIXME: I'm having problem parsing Compound Lists, so this is out for now.
		/*var writer1:NbtWriter = new NbtWriter();
		writer1.writeCompound("",true);
		writer1.writeString("test", "test");
		writer1.writeEnd();
		var bytes = writer1.getOutput().getBytes();
		
		var writer2:NbtWriter = new NbtWriter();
		writer2.writeCompound("", true);
		writer2.writeInt("int", 323);
		writer2.writeEnd();
		var bytes2 = writer2.getOutput().getBytes();*/
	
		nbt.writeCompound("lists");
		nbt.writeByteList("byteList", [1, 2, 3, 4, 5]);
		nbt.writeByteArrayList("byteArrayList", [Bytes.ofString("AAAAA"), Bytes.ofString("BBBBB")]);
		nbt.writeShortList("shortList", [1, 2, 3]);
		nbt.writeIntList("intList", [1, 2, 3]);
		nbt.writeFloatList("floatList", [1.34, 2.45, 3.12]);
		nbt.writeIntArrayList("intArrayList", [[1, 2, 3], [3, 4, 1]]);
		nbt.writeDoubleList("doubleList", [12.4, 304.2, 232.4]);
		nbt.writeLongList("longList", ["9223372036854775807", "9223372036854775807", "9223372036854775807"]);
		//nbt.writeList("compoundList", NbtTag.TAG_COMPOUND, [bytes,bytes2]);
		nbt.writeEnd(); //Closing "Lists"
		
		nbt.writeEnd();//Closing "Root"
		nbt.closeAndSave("test.nbt");
	}
	
	static private function readNBTFile():Void 
	{
		var fin = File.read("test.nbt", true);
		var parser = new NbtParser();
		parser.parseNBTFile(fin, true, "test.json", false);
	}
	
	private static function readNBTData():Void
	{
		var nbt:NbtWriter = new NbtWriter();
		nbt.writeCompound("root");
		nbt.writeString("data", "data");
		nbt.writeEnd();
		
		var parser = new NbtParser();
		parser.parseNBTData(nbt.getOutput().getBytes(), true, "test2.json", false);
	}
	
	public static function readCompressedNBTData():Void
	{
		var nbt:NbtWriter = new NbtWriter();
		nbt.writeCompound("root");
		nbt.writeString("data", "data");
		nbt.writeEnd();
		
		var parser = new NbtParser();
		parser.parseNBTData(nbt.getCompressedOutput().getBytes(), true, "test2.json", true);
	}
	
}