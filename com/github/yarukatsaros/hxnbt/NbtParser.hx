package com.github.yarukatsaros.hxnbt;
import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.Json;
import openfl.utils.ByteArray;
import openfl.utils.CompressionAlgorithm;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;

/**
 * ...
 * @author Yaru
 */
class NbtParser
{

	var _file:BytesInput;
	var _object:String;
	var _outputName:String;
	
	var _openCompounds:Int = 1;
	
	public function new():Void 
	{
		
	}	
	
	/**
	 * Parses a NBT file into a Json String, with options to turn it into a dynamic object or write it in a file.
	 * @param	fileInput The data of the file to parse.
	 * @param	bigEndian This should be true in almost every case.
	 * @param	outputName If not empty, the parser will write the output, as Json, into this file once finished.
	 * @param	isCompressed If true, the parser will try to uncompress the file using GZIP before parsing.
	 */
	public function parseNBTFile(fileInput:FileInput, bigEndian:Bool, outputName:String, isCompressed:Bool = false)
	{
		if (isCompressed) {
			try 
			 {
				 var ba:ByteArray = new ByteArray();
				 ba.writeBytes(fileInput.readAll());
				 ba.uncompress(CompressionAlgorithm.GZIP);
				 _file = new BytesInput(ba);
			 } 
			 catch (e:Dynamic) 
			 {
				 throw("Something went wrong uncompressing the file! Are you sure it's compressed?\n" + e);
			 }
		}
		else {
			_file = new BytesInput(fileInput.readAll());
		}
		fileInput.close();
		_file.bigEndian = bigEndian;
		_outputName = outputName;
		_object = "{";
		readFile(_file.readByte());		
	}
	
	/**
	 * Parses the Bytes output of a NbtWriter into a Json String, with options to turn it into a dynamic object or write it in a file.
	 * @param	bytes NbtWriter.getOutput() or .getCompressedOutput()
	 * @param	bigEndian This should be true in almost every case.
	 * @param	outputName If not empty, the parser will write the output, as Json, into this file once finished.
	 * @param	isCompressed If true, the parser will try to uncompress the file using GZIP before parsing.
	 */
	public function parseNBTData(bytes:Bytes, bigEndian:Bool, outputName:String, isCompressed:Bool = false)
	{
		if (isCompressed) {
			try 
			 {
				 var ba:ByteArray = new ByteArray();
				 ba.writeBytes(bytes);
				 ba.uncompress(CompressionAlgorithm.GZIP);
				 _file = new BytesInput(ba);
			 } 
			 catch (e:Dynamic) 
			 {
				 throw("Something went wrong uncompressing the file! Are you sure it's compressed?\n" + e);
			 }
		}
		else {
			_file = new BytesInput(bytes);
		}
		_file.bigEndian = bigEndian;
		_outputName = outputName;
		_object = "{";
		readFile(_file.readByte());				
	}
	
	private function readFile(byte:Int) 
	{
		switch (byte) 
		{
			case NbtTag.TAG_END:
				parseEnd();
			case NbtTag.TAG_BYTE:
				parseByte();
			case NbtTag.TAG_SHORT:
				parseShort();
			case NbtTag.TAG_INT:
				parseInt();
			case NbtTag.TAG_LONG:
				parseLong();
			case NbtTag.TAG_FLOAT:
				parseFloat();
			case NbtTag.TAG_DOUBLE:
				parseDouble();
			case NbtTag.TAG_BYTE_ARRAY:
				parseByteArray();
			case NbtTag.TAG_STRING:
				parseString();
			case NbtTag.TAG_LIST:
				parseList();
			case NbtTag.TAG_COMPOUND:
				parseCompound();
			case NbtTag.TAG_INT_ARRAY:
				parseIntArray();
			default:
				throw("Unknown tag " + byte);
		}
	}
	
	private function parseEnd():Void
	{
		_object += '}';
		_openCompounds --;
		if (_file.position < _file.length) {
			readFile(_file.readByte());
		}
		else {
			while (_openCompounds > 0) 
			{
				_object += "}";				
				_openCompounds --;
			}
			if (_outputName != "") {
				exportFileAsJson();				
			}
		}
	}
	
	private function parseByte():Void
	{
		if (_object.charAt(_object.length - 1) != ":" && _object.charAt(_object.length - 1) != "{") {
			_object += ",";			
		}
		var nameLength = _file.readInt16();
		var tagName:String = _file.readString(nameLength);
		var byte:Int = _file.readByte();
		_object += '"$tagName":$byte';
		if (_file.position < _file.length) {
			readFile(_file.readByte());
		}
	}
	
	private function parseShort():Void
	{
		if (_object.charAt(_object.length - 1) != ":" && _object.charAt(_object.length - 1) != "{") {
			_object += ",";			
		}
		var nameLength = _file.readInt16();
		var tagName:String = _file.readString(nameLength);
		var short = _file.readInt16();
		_object += '"$tagName":$short';
		if (_file.position < _file.length) {
			readFile(_file.readByte());
		}		
	}
	
	private function parseInt():Void
	{
		if (_object.charAt(_object.length - 1) != ":" && _object.charAt(_object.length - 1) != "{") {
			_object += ",";			
		}
		var nameLength = _file.readInt16();
		var tagName:String = _file.readString(nameLength);
		var int32 = _file.readInt32();
		_object += '"$tagName":$int32';
		if (_file.position < _file.length) {
			readFile(_file.readByte());
		}		
	}
	
	private function parseLong():Void
	{
		if (_object.charAt(_object.length - 1) != ":" && _object.charAt(_object.length - 1) != "{") {
			_object += ",";			
		}
		var nameLength = _file.readInt16();
		var tagName:String = _file.readString(nameLength);
		var i1 = _file.readInt32();
		var i2 = _file.readInt32();
		var i64 = Int64.make(i1, i2);
		_object += '"$tagName":$i64';
		if (_file.position < _file.length) {
			readFile(_file.readByte());
		}		
	}
	
	private function parseFloat():Void
	{
		if (_object.charAt(_object.length - 1) != ":" && _object.charAt(_object.length - 1) != "{") {
			_object += ",";			
		}
		var nameLength = _file.readInt16();
		var tagName:String = _file.readString(nameLength);
		var float = _file.readFloat();
		_object += '"$tagName":$float';
		if (_file.position < _file.length) {
			readFile(_file.readByte());
		}		
	}
	
	private function parseDouble():Void
	{
		if (_object.charAt(_object.length - 1) != ":" && _object.charAt(_object.length - 1) != "{") {
			_object += ",";			
		}
		var nameLength = _file.readInt16();
		var tagName:String = _file.readString(nameLength);
		var double = _file.readDouble();
		_object += '"$tagName":$double';
		if (_file.position < _file.length) {
			readFile(_file.readByte());
		}		
	}
	
	private function parseByteArray():Void
	{
		if (_object.charAt(_object.length - 1) != ":" && _object.charAt(_object.length - 1) != "{") {
			_object += ",";			
		}
		var nameLength = _file.readInt16();
		var tagName:String = _file.readString(nameLength);
		var bytesLength = _file.readInt32();
		var bytesArray:Array<Int> = new Array<Int>();
		for (i in 0...bytesLength) 
		{
			bytesArray.push(_file.readByte());
		}
		_object += '"$tagName":$bytesArray';
		if (_file.position < _file.length) {
			readFile(_file.readByte());
		}		
	}
	
	private function parseString():Void
	{
		if (_object.charAt(_object.length - 1) != ":" && _object.charAt(_object.length - 1) != "{") {
			_object += ",";			
		}
		var nameLength = _file.readInt16();
		var tagName:String = _file.readString(nameLength);
		var stringLength = _file.readInt16();
		var string:String = StringTools.replace(_file.readString(stringLength), '\\', '\\\\'); //I THINK this solves the problem with slashes on strings. Please do.
		_object += '"$tagName":"$string"';
		if (_file.position < _file.length) {
			readFile(_file.readByte());
		}		
	}
	
	private function parseList():Void
	{
		if (_object.charAt(_object.length - 1) == "}" || _object.charAt(_object.length - 1) == "]" || _object.charAt(_object.length - 1) == '"') {
			_object += ",";
		}
		var nameLength = _file.readInt16();
		var tagName:String = _file.readString(nameLength);
		var type = _file.readByte();
		var listLength = _file.readInt32();
		var a:Array<Dynamic> = new Array<Dynamic>();
		switch (type) 
		{
			case 1: //BYTE
				for (i in 0...listLength) 
				{
					a.push(_file.readByte());
				}
			case 2: //SHORT
				for (j in 0...listLength) 
				{
					a.push(_file.readInt16());
				}
			case 3: //INT
				for (k in 0...listLength) 
				{
					a.push(_file.readInt32());
				}
			case 4: //LONG
				for (r in 0...listLength) 
				{
					var i1 = _file.readInt32();
					var i2 = _file.readInt32();
					var i64:String = Std.string(Int64.make(i1, i2));
					a.push(i64);
				}
			case 5: //FLOAT
				for (l in 0...listLength) 
				{
					a.push(_file.readFloat());
				}
			case 6: //DOUBLE
				for (p in 0...listLength) 
				{
					a.push(_file.readDouble());
				}
			case 7: //BYTEARRAY
				for (m in 0...listLength) 
				{
					var baLength = _file.readInt32();
					var ints:Array<Int> = new Array<Int>();
					for (n in 0...baLength) 
					{
						ints.push(_file.readByte());
					}
					a.push(ints);
				}
			case 8: //STRING
				for (o in 0...listLength) 
				{
					var stringLength = _file.readInt16();
					a.push(_file.readString(stringLength));
				}
			case 10: //COMPOUND
				throw("Compound lists aren't supported yet. Please help!");
			case 11: //INTARRAY
				for (q in 0...listLength) 
				{
					var iaLength = _file.readInt32();
					var b:Array<Int> = new Array<Int>();
					for (q in 0...iaLength) 
					{
						b.push(_file.readInt32());
					}
					a.push(b);
				}
			default:
				throw("Unknown list type: " + type);
		}
		_object += '"$tagName":$a';
		if (_file.position < _file.length) {
			readFile(_file.readByte());
		}		
	}
	
	private function parseCompound():Void
	{
		if (_object.length != 0 && _object.charAt(_object.length -1) != ":" && _object.charAt(_object.length -1) != "{") {
			_object += ",";
		}
		var nameLength:Int = _file.readInt16();
		var tagName:String = _file.readString(nameLength);
		_object += '"$tagName":{';
		_openCompounds++;
		if (_file.position < _file.length) {
			readFile(_file.readByte());
		}
	}
	
	private function parseIntArray():Void
	{
		if (_object.charAt(_object.length - 1) != ":") {
			_object += ",";			
		}
		var nameLength:Int = _file.readInt16();
		var tagName:String = _file.readString(nameLength);
		var arrayLength = _file.readInt32();
		var arrayInt:Array<Int> = new Array<Int>();
		for (i in 0...arrayLength) 
		{
			arrayInt.push(_file.readInt32());
		}
		_object += '"$tagName":$arrayInt';
		if (_file.position < _file.length) {
			readFile(_file.readByte());
		}		
	}
	
	/**
	 * Returns the contents of the file as a string, with no parsing.
	 * @return
	 */
	public function getObjectAsString():String
	{
		return _object;
	}
	
	/**
	 * The contents of the NBT file, parsed into a Dynamic object.
	 * @return A Json-parsed dynamic object.
	 */
	public function getObjectAsJson():Dynamic
	{
		return Json.parse(_object);
	}

	function exportFileAsJson():Void 
	{
		var fout:FileOutput = File.write(_outputName, false);
		fout.writeString(Json.stringify(getObjectAsJson()));
		fout.close();
	}
	
}