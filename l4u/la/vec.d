module l4u.la.vec;

unittest 
{
	import std.stdio;
	
	writeln("vector unittest\n{");
	
	{
		vec!(int,3) intvec3 = vec!(int,3)(1,2,3);
		vec!(float,3) floatvec3 = vec!(float,3)(intvec3);
		floatvec3 = intvec3;
		assert(intvec3.z == 3);
		assert((-floatvec3).y < -1.0f);
		writeln(" ctor and copy test passed");
	}
	
	{
		vec!(int,4) a = vec!(int,4)(1,1,1,1), b = vec!(int,4)(1,1,1,-1);
		assert((a + b).w == 0);
		assert((a & b).w == -1);
		assert((a * 2).w == 2);
		assert(a*b == 2);
		assert((ivec2(1,0)^ivec2(0,1)) == 1);
		writeln(" basic operators test passed");
	}
	
	{
		vec!(int,4) a = vec!(int,4)(1,1,1,1), b = vec!(int,4)(1,1,1,-1);
		assert((2 * a).w == 2);
		assert((a - b).w == 2);
		assert(((a + b)/2).z == 1);
		writeln(" derivative operators test passed");
	}
	
	{
		vec!(int,4) a = vec!(int,4)(0,0,0,0), b = vec!(int,4)(1,1,1,1);
		assert((a += 2*b).w == 2);
		assert((a -= b).w == 1);
		assert((a *= 2).w == 2);
		assert((a /= 2).w == 1);
		writeln(" assign operators test passed");
	}
	
	{
		vec!(float,4) a = vec!(float,4)(1,1,1,1);
		assert(sqr(a) > 3.999 && sqr(a) < 4.001);
		assert(length(a) > 1.999 && length(a) < 2.001);
		assert(norm(a).x > 0.499 && norm(a).x < 0.501);
		writeln(" math test passed");
	}
	
	{
		vec!(int,4) a = vec!(int,4)(1,1,1,1);
		assert(a == a);
		assert(a != 2*a);
		writeln(" comparison test passed");
	}
	writeln("}");
}

/* Vector struct */
@system
struct vec(T, uint N) 
{
public:
	T[N] data;
	
	/* Constructors */
	this(S...)(S args) 
	{
		import std.traits;
		static if(args.length == 1 && isPointer!(S[0]))
		{
			const T *p = args[0];
			for(int i = 0; i < N; ++i) {
				data[i] = p[i];
			}
		}
		else static if(args.length == 2 && isPointer!(S[0]) && isIntegral!(S[1]))
		{
			const T *p = args[0];
			int d = args[1];
			for(int i = 0; i < N; ++i) {
				data[i] = p[d*i];
			}
		}
		else static if(args.length == N)
		{
			foreach(i, ref c; args)
			{
				data[i] = cast(T)c;
			}
		}
		else
		{
			static assert(args.length == N*M,"wrong number of arguments");
		}
	}
	this(S)(auto const ref vec!(S,N) v)
	{
		for(int i = 0; i < N; ++i)
		{
			data[i] = cast(T)v.data[i];
		}
	}
	
	/* Assign operator */
	ref vec!(T,N) opAssign(S)(auto const ref vec!(S,N) v)
	{
		for(int i = 0; i < N; ++i)
		{
			data[i] = cast(T)v.data[i];
		}
		return this;
	}
	
	/* Getters and setters */
	@property 
	T get(int comp)() const {
		static assert(comp >= 0 && comp < N, "index is out of bounds");
		return data[comp];
	}
	@property 
	void set(int comp)(T val) {
		static assert(comp >= 0 && comp < N, "index is out of bounds");
		data[comp] = val;
	}
	
	/* Index access properties */
	static if(N > 0 && N <= 4) {
		alias get!0 x;
		alias set!0 x;
		static if(N > 1) {
			alias get!1 y;
			alias set!1 y;
			static if(N > 2) {
				alias get!2 z;
				alias set!2 z;
				static if(N > 3) {
					alias get!3 w;
					alias set!3 w;
				}
			}
		}
	}
	
	/* Index access */
	T opIndex()(uint n) const
	{
		return data[n];
	}
	ref T opIndex()(uint n)
	{
		return data[n];
	}
	
	/* Unary plus */
	vec!(T,N) opUnary(string op : "+")() const 
	{
		return this;
	}
	/* Unary minus */
	vec!(T,N) opUnary(string op : "-")() const 
	{
		vec!(T,N) c;
		c.data[] = -data[];
		return c;
	}
	
	/* Basic operations */
	 /* Addition */
	vec!(T,N) opBinary(string op : "+")(auto const ref vec!(T,N) b) const
	{
		vec!(T,N) c;
		c.data[] = data[] + b.data[];
		return c;
	}
	 /* Multiplication by constatnt */
	vec!(T,N) opBinary(string op : "*", S)(S a) const
	{
		vec!(T,N) c;
		c.data[] = cast(T)a*data[];
		return c;
	}

	 /* Component product */
	vec!(T,N) opBinary(string op : "&")(auto const ref vec!(T,N) b) const
	{
		vec!(T,N) c;
		c.data[] = data[]*b.data[];
		return c;
	}

	 /* Scalar product */
	T opBinary(string op : "*")(auto const ref vec!(T,N) b) const
	{
		T c = cast(T)0;
		for(int i = 0; i < N; ++i) {
			c += data[i]*b.data[i];
		}
		return c;
	}
	
	 /* Cross product */
	static if(N == 3)
	{
		vec!(T,N) opBinary(string op : "^")(auto const ref vec!(T,N) b) const
		{
			return vec!(T,N)(
			  this[1]*b[2] - b[1]*this[2],
			  this[2]*b[0] - b[2]*this[0],
			  this[0]*b[1] - b[0]*this[1]
			);
		}
	}
	static if(N == 2)
	{
		T opBinary(string op : "^")(auto const ref vec!(T,N) b) const
		{
			return this[0]*b[1] - this[1]*b[0];
		}
	}
	
	
	/* Derivative operations */
	vec!(T,N) opBinaryRight(string op : "*", S)(S a) const
	{
		return this*cast(T)a;
	}
	
	vec!(T,N) opBinary(string op : "-")(auto const ref vec!(T,N) b) const
	{
		vec!(T,N) c;
		c.data[] = data[] - b.data[];
		return c;
	}
	
	vec!(T,N) opBinary(string op : "/", S)(S a) const
	{
		import std.traits;
		static if(isIntegral!S)
		{
			vec!(T,N) c;
			for(int i = 0; i < N; ++i)
			{
				c.data[i] = data[i]/cast(T)a;
			}
			return c;
		}
		else
		{
			return this*(cast(T)1/cast(T)a);
		}
	}
	
	/* Assign operations */
	ref vec!(T,N) opOpAssign(string op : "+", S)(auto const ref vec!(S,N) b) 
	{
		for(int i = 0; i < N; ++i)
		{
			data[i] = data[i] + cast(T)b.data[i];
		}
		return this;
	}
	
	ref vec!(T,N) opOpAssign(string op : "-", S)(auto const ref vec!(S,N) b) 
	{
		for(int i = 0; i < N; ++i)
		{
			data[i] = data[i] - cast(T)b.data[i];
		}
		return this;
	}
	
	ref vec!(T,N) opOpAssign(string op : "*", S)(S b) 
	{
		return this = this*cast(T)b;
	}
	
	vec!(T,N) opOpAssign(string op : "/", S)(S b) 
	{
		return this = this/cast(T)b;
	}
	
	/* Comparison */
	bool opEquals()(auto const ref vec!(T,N) v) const 
	{
		foreach(i, ref comp; data) {
			if(comp != v.data[i]) {
				return false;
			}
		}
		return true;
	}
}

/* Math */
import std.math;

T sqr(T, uint N)(auto const ref vec!(T,N) v)
{
	return v*v;
}

T length(T, uint N)(auto const ref vec!(T,N) v)
{
	return sqrt(sqr(v));
}

vec!(T,N) norm(T, uint N)(auto const ref vec!(T,N) v)
{
	return v/length(v);
}

/* Short typenames */
alias dvec2 = vec!(double,2);
alias dvec3 = vec!(double,3);
alias dvec4 = vec!(double,4);
alias fvec2 = vec!(float,2);
alias fvec3 = vec!(float,3);
alias fvec4 = vec!(float,4);
alias ivec2 = vec!(int,2);
alias ivec3 = vec!(int,3);
alias ivec4 = vec!(int,4);

alias vec2 = dvec2;
alias vec3 = dvec3;
alias vec4 = dvec4;

/* Constants */
const dvec2 nulldvec2 = dvec2(0,0);
const dvec3 nulldvec3 = dvec3(0,0,0);
const dvec4 nulldvec4 = dvec4(0,0,0,0);
const fvec2 nullfvec2 = fvec2(0,0);
const fvec3 nullfvec3 = fvec3(0,0,0);
const fvec4 nullfvec4 = fvec4(0,0,0,0);
const ivec2 nullivec2 = ivec2(0,0);
const ivec3 nullivec3 = ivec3(0,0,0);
const ivec4 nullivec4 = ivec4(0,0,0,0);

const vec2 nullvec2 = nulldvec2;
const vec3 nullvec3 = nulldvec3;
const vec4 nullvec4 = nulldvec4;
