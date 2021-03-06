module validators;

import std.conv, std.regex;
import qc, fields;

abstract class Validator
{
	protected:
	public:
		string[] errors;
		string errorMsg;
		
		abstract:
			bool valid (in string) @safe const;
			bool valid (in int) @safe const;
			bool valid (in uint) @safe const;
			bool valid (in bool) @safe const;
			string js () @safe const;
}

class FilledValidator: Validator
{
	public:
		static string key = "filled";
		
		bool valid (in string s) @safe const
		{
			return s !is null && s.length;
		}
		bool valid (in int v) @safe const
		{
			return true;
		}
		bool valid (in uint v) @safe const
		{
			return true;
		}
		bool valid (in bool b) @safe const
		{
			return true;
		}
		string js () @safe const
		{
			return "validFilled()";
		}
		
	unittest
	{
		auto v = new FilledValidator;
		assert(!v.valid(""));
		assert(!v.valid(null));
		assert(v.valid("a"));
		assert(v.valid(3));
	}
}

class LengthValidator: Validator
{
	public:
		static string key = "length";
		
		uint min = uint.min, max = uint.max;
		
		this (in uint min, in uint max)
		{
			this.min = min;
			this.max = max;
		}
		this (in uint max)
		{
			this.max = max;
		}
		bool valid (in string s) @safe const
		{
			return s.length >= min && s.length <= max;
		}
		bool valid (in int v) @trusted const
		{
			return valid(to!string(v));
		}
		bool valid (in uint v) @trusted const
		{
			return valid(to!string(v));
		}
		bool valid (in bool v) @safe const
		{
			assert(false, "not implemented");
		}
		string js () @trusted const
		{
			return "validLength(" ~ to!string(min) ~ ", "
				~ (max? to!string(max) : "null") ~ ")";
		}
	
	unittest
	{
		auto v = new LengthValidator(3, 5);
		assert(!v.valid(12));
		assert(v.valid(123));
		assert(v.valid(1234));
		assert(v.valid(12345));
		assert(!v.valid(123456));
		assert(!v.valid(""));
		assert(!v.valid("ab"));
		assert(v.valid("abc"));
		assert(v.valid("abcde"));
		assert(!v.valid("abcdef"));
	}
}

class IntValidator: Validator
{
	public:
		static string key = "int";
		
		bool valid (in string s) @trusted const
		{
			try
			{
				auto v = to!int(s);
			}
			catch
			{
				return false;
			}
			return true;
		}
		bool valid (in int v) @safe const
		{
			return true;
		}
		bool valid (in uint v) @safe const
		{
			return true;
		}
		bool valid (in bool b) @safe const
		{
			return false;
		}
		string js () @safe const
		{
			return "validInt()";
		}
		
	unittest
	{
		auto v = new IntValidator;
		assert(!v.valid(""));
		assert(!v.valid("abcd"));
		assert(v.valid("12345"));
		assert(v.valid("-245"));
	}
}

/+
class RegexpValidator: Validator
{		
	public:
		static string key = "regexp";
		
		string regexp;
		
		this (in string s)
		{
			regexp = s;
		}
		bool valid (in string s)
		{
			return !match(s, regex(regexp)).empty;
		}
		bool valid (in int v)
		{
			return valid(to!string(v));
		}
		bool valid (in uint v)
		{
			return valid(to!string(v));
		}
		bool valid (in bool b)
		{
			assert(false, "not implemented");
		}
	
	unittest
	{
		auto v = new RegexpValidator("^abc");
		assert(!v.valid(""));
		assert(!v.valid(null));
		assert(!v.valid("ab"));
		assert(v.valid("abc"));
		assert(v.valid("abcdef"));
	}
}+/
