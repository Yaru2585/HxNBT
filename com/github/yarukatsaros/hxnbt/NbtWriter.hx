package com.github.yarukatsaros.hxnbt;
import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import openfl.utils.ByteArray;
import openfl.utils.CompressionAlgorithm;
import sys.io.File;
import sys.io.FileOutput;
import thx.Int64s;

/**
 * ...
 * @author Yaru
 */
class NbtWriter
{

	private var _bytes:BytesOutput;
	
	public function new() 
	{
		_bytes = new BytesOutput();
		_bytes.bigEndian = true;
	}
	
	/**
	 * Closes the last compound opened.
	 * Format: 0x0.
	 */
	public function writeEnd():Void
	{
		_bytes.writeByte(0);
	}
	
	/**
	 * A single signed byte
	 * Format: 0x1(id) + int16(Length of the name) + string(name) + byte.
	 * @param	name Name of the tag.
	 * @param	byte Byte.
	 */
	public function writeByte(name:String,byte:Int):Void
	{
		_bytes.writeByte(1);
		_bytes.writeInt16(name.length);
		_bytes.writeString(name);
		_bytes.writeByte(byte);
	}
	
	/**
	 * A single signed, big endian 16 bit integer.
	 * Format: 0x2(id) + int16(Name length) + string(name) + int16(short)
	 * @param	name Name of the tag
	 * @param	short A 16 bit integer.
	 */
	public function writeShort(name:String,short:Int):Void
	{
		_bytes.writeByte(2);
		_bytes.writeInt16(name.length);
		_bytes.writeString(name);
		_bytes.writeInt16(short);
	}
	
	/**
	 * A single signed, big endian 32 bit integer
	 * format: 0x3(id) + int16(Name Length) + string(name) + int32(int)
	 * @param	name Name of the tag
	 * @param	int A 32 bit integer.
	 */
	public function writeInt(name:String,int:Int):Void
	{
		_bytes.writeByte(3);
		_bytes.writeInt16(name.length);
		_bytes.writeString(name);
		_bytes.writeInt32(int);
	}
	
	/**
	 * A single signed, big endian 64 bit integer.
	 * Format: 0x4 + int16(Name length) + string(name) + stringToInt(string)
	 * @param	name Name of the tag.
	 * @param	stringToInt A string with the int64. The method will parse it using thx.Int64s
	 */
	public function writeLong(name:String,stringToInt:String):Void
	{
		try 
		 {
			 _bytes.writeByte(4);
			 _bytes.writeInt16(name.length);
			 _bytes.writeString(name);
			 var i:Int64 = Int64s.parse(stringToInt);
			 _bytes.writeInt32(i.high);
			 _bytes.writeInt32(i.low);	
		 } 
		 catch (e:Dynamic) 
		 {
			 throw ("Something went wrong parsing the Int64! Did you install the dependencies?\n" + e);
		 }
	}
	
	/**
	 * A single, big endian IEEE-754 single-precision floating point number.
	 * Format: 0x5 + int16(Name length) + string(name) + float(float)
	 * @param	name Name of the tag
	 * @param	float
	 */
	public function writeFloat(name:String,float:Float):Void {
		_bytes.writeByte(5);
		_bytes.writeInt16(name.length);
		_bytes.writeString(name);
		_bytes.writeFloat(float);
	}
	
	/**
	 * A single, big endian IEEE-754 double-precision floating point number.
	 * Format: 0x6 + int16(Name length) + string(name) + double(double)
	 * @param	name Name of the tag
	 * @param	double
	 */
	public function writeDouble(name:String,double:Float):Void
	{
		_bytes.writeByte(6);
		_bytes.writeInt16(name.length);
		_bytes.writeString(name);
		_bytes.writeDouble(double);
	}
	
	/**
	 * A length-prefixed array of signed bytes. The prefix is a signed integer (thus 4 bytes)
	 * Format: 0x7 + int16(Name length) + string(name) + int32(bytes.length) + bytes
	 * @param	name Name of the tag
	 * @param	bytes
	 */
	public function writeByteArray(name:String,bytes:Bytes):Void
	{
		_bytes.writeByte(7);
		_bytes.writeInt16(name.length);
		_bytes.writeString(name);
		_bytes.writeInt32(bytes.length);
		_bytes.write(bytes);
	}
	
	/**
	 * A length-prefixed UTF-8 string. The prefix is an unsigned short (thus 2 bytes) signifying the length of the string in bytes
	 * Fornat: 0x8 + int16(Name length) + string(name) + int16(string.length) + string
	 * @param	name Name of the tag
	 * @param	string
	 */
	public function writeString(name:String,string:String):Void
	{
		_bytes.writeByte(8);
		_bytes.writeInt16(name.length);
		_bytes.writeString(name);
		_bytes.writeInt16(string.length);
		_bytes.writeString(string);
	}
	
	/**
	 * A list of nameless tags, all of the same type. The list is prefixed with the Type ID of the items it contains (thus 1 byte), and the length of the list as a signed integer (a further 4 bytes)
	 * @param	name Name of the tag
	 * @param	list An array of Ints.
	 */
	public function writeByteList(name:String, list:Array<Int>):Void
	{
		writeListHeader(NbtTag.TAG_BYTE, name, list);
		for (i in 0...list.length) 
		{
			_bytes.writeByte(list[i]);
		}
	}
	
	/**
	 * A list of nameless tags, all of the same type. The list is prefixed with the Type ID of the items it contains (thus 1 byte), and the length of the list as a signed integer (a further 4 bytes)
	 * @param	name Name of the tag
	 * @param	list
	 */	
	public function writeShortList(name:String, list:Array<Int>):Void
	{
		writeListHeader(NbtTag.TAG_SHORT, name, list);
		for (i in 0...list.length) 
		{
			_bytes.writeInt16(list[i]);
		}
	}
	
	/**
	 * A list of nameless tags, all of the same type. The list is prefixed with the Type ID of the items it contains (thus 1 byte), and the length of the list as a signed integer (a further 4 bytes)
	 * @param	name Name of the tag
	 * @param	list
	 */
	public function writeIntList(name:String, list:Array<Int>):Void
	{
		writeListHeader(NbtTag.TAG_INT, name, list);
		for (i in 0...list.length) 
		{
			_bytes.writeInt32(list[i]);
		}
	}
	
	/**
	 * A list of nameless tags, all of the same type. The list is prefixed with the Type ID of the items it contains (thus 1 byte), and the length of the list as a signed integer (a further 4 bytes)
	 * @param	name Name of the tag.
	 * @param	list
	 */	
	public function writeLongList(name:String, list:Array<String>):Void
	{
		writeListHeader(NbtTag.TAG_LONG, name, list);
		for (i in 0...list.length) 
		{
			var i:Int64 = Int64s.parse(list[i]);
			_bytes.writeInt32(i.high);
			_bytes.writeInt32(i.low);
		}
	}

	/**
	 * A list of nameless tags, all of the same type. The list is prefixed with the Type ID of the items it contains (thus 1 byte), and the length of the list as a signed integer (a further 4 bytes)
	 * @param	name Name of the tag
	 * @param	list
	 */	
	public function writeFloatList(name:String, list:Array<Float>):Void
	{
		writeListHeader(NbtTag.TAG_FLOAT, name, list);
		for (i in 0...list.length) 
		{
			_bytes.writeFloat(list[i]);
		}
	}
	
	/**
	 * A list of nameless tags, all of the same type. The list is prefixed with the Type ID of the items it contains (thus 1 byte), and the length of the list as a signed integer (a further 4 bytes)
	 * @param	name Name of the tag
	 * @param	list
	 */	
	public function writeDoubleList(name:String, list:Array<Float>):Void
	{
		writeListHeader(NbtTag.TAG_DOUBLE, name, list);
		for (i in 0...list.length) 
		{
			_bytes.writeDouble(list[i]);
		}
	}

	/**
	 * A list of nameless tags, all of the same type. The list is prefixed with the Type ID of the items it contains (thus 1 byte), and the length of the list as a signed integer (a further 4 bytes)
	 * @param	name Name of the tag
	 * @param	list
	 */	
	public function writeByteArrayList(name:String, list:Array<Bytes>):Void
	{
		writeListHeader(NbtTag.TAG_BYTE_ARRAY, name, list);
		for (i in 0...list.length) 
		{
			_bytes.writeInt32(list[i].length);
			_bytes.write(list[i]);
		}
	}
	
	/**
	 * A list of nameless tags, all of the same type. The list is prefixed with the Type ID of the items it contains (thus 1 byte), and the length of the list as a signed integer (a further 4 bytes)
	 * @param	name Name of the tag
	 * @param	list
	 */	
	public function writeStringList(name:String, list:Array<String>):Void
	{
		writeListHeader(NbtTag.TAG_STRING, name, list);
		for (i in 0...list.length) 
		{
			_bytes.writeInt16(list[i].length);
			_bytes.writeString(list[i]);
		}
	}
	
	/**
	 * A list of nameless tags, all of the same type. The list is prefixed with the Type ID of the items it contains (thus 1 byte), and the length of the list as a signed integer (a further 4 bytes)
	 * @param	name Name of the tag
	 * @param	list
	 */	
	public function writeCompoundList(name:String, list:Array<Bytes>):Void
	{
		writeListHeader(NbtTag.TAG_COMPOUND, name, list);
		for (i in 0...list.length) 
		{
			_bytes.write(list[i]);
		}
	}
	
	/**
	 * A list of nameless tags, all of the same type. The list is prefixed with the Type ID of the items it contains (thus 1 byte), and the length of the list as a signed integer (a further 4 bytes)
	 * @param	name Name of the tag
	 * @param	list
	 */	
	public function writeIntArrayList(name:String, list:Array<Array<Int>>):Void
	{
		writeListHeader(NbtTag.TAG_INT_ARRAY, name, list);
		for (i in 0...list.length) 
		{
			_bytes.writeInt32(list[i].length);
			for (j in 0...list[i].length) 
			{
				_bytes.writeInt32(list[i][j]);
			}
		}
	}
	
	/**
	 * Effectively a list of a named tags. Order is not guaranteed.
	 * Format: 0xa(id) + int16(Name length) + string(name)
	 * @param	name Name of the tag.
	 * @param	onCompoundList If true, this method doesn't write anything. Use it when creating a compound you will add to a Compound List.
	 */
	public function writeCompound(name:String,onCompoundList:Bool = false):Void
	{
		if (!onCompoundList) {
			_bytes.writeByte(10);			
			_bytes.writeInt16(name.length);
			_bytes.writeString(name);			
		}	
	}
	
	/**
	 * A length-prefixed array of signed integers. The prefix is a signed integer (thus 4 bytes) and indicates the number of 4 byte integers.
	 * @param	name Name of the tag
	 * @param	array
	 */
	public function writeIntArray(name:String,array:Array<Int>):Void
	{
		_bytes.writeByte(11);
		_bytes.writeInt16(name.length);
		_bytes.writeString(name);
		_bytes.writeInt32(array.length);
		for (i in 0...array.length) 
		{
			_bytes.writeInt32(array[i]);
		}
	}
	
	/**
	 * Writes the object into a file. WARNING: Do not keep using this NbtWriter instance after calling this method.
	 * @param	fileName The name of the file you're creating, usually with the extension ".nbt".
	 * @param	applyCompression If true, the file will be compressed using GZIP.
	 */
	public function closeAndSave(fileName:String,applyCompression:Bool = false)
	{
		var fout:FileOutput = File.write(fileName, true);
		if (applyCompression) {
			try 
			{
				var ba:ByteArray = new ByteArray();
				ba.writeBytes(_bytes.getBytes());
				ba.compress(CompressionAlgorithm.GZIP);
				fout.write(ba);
			} 
			catch (e:Dynamic) 
			{
				throw ("Something went wrong compressing the file! Did you install the dependencies?\n" + e);				
			}
		}
		else {
			fout.write(_bytes.getBytes());			
		}
		fout.close();
	}
	
	/**
	 * Returns the writer object.
	 * @return A BytesOutput with the written data and no compression.
	 */
	public function getOutput():BytesOutput
	{
		return _bytes;
	}
	
	/**
	 * Returns the writer object (as a ByteArray) after compressing it with GZIP. WARNING: Do not use this instance after calling this method.
	 * @return A ByteArray with the written data, compressed with GZIP.
	 */
	public function getCompressedOutput():BytesOutput
	{
		var ba:ByteArray = new ByteArray();
		ba.writeBytes(_bytes.getBytes());
		ba.compress(CompressionAlgorithm.GZIP);
		var bo:BytesOutput = new BytesOutput();
		bo.write(ba);
		_bytes.close();
		ba.clear();
		return bo;
	}
	
	private function writeListHeader(type:Int,name:String,list:Array<Dynamic>)
	{
		_bytes.writeByte(9);
		_bytes.writeInt16(name.length);
		_bytes.writeString(name);
		_bytes.writeByte(type);
		_bytes.writeInt32(list.length);
	}	
	
}