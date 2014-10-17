module l4u.la.mat;

unittest
{
	import std.stdio;
	writeln("matrix unittest\n{");
	{
		imat2 a = uniimat2;
		fmat2 b = a;
		a = b;
		assert(a.data[0] == 1);
		a = fmat2(nullfvec2,nullfvec2);
		assert(a.data[0] == 0);
		writeln(" ctor and assign test passed");
	}
	{
		assert(uniimat3[ivec2(2,2)] == 1);
		assert(uniimat4[3,3] == 1);
		for(int i = 0; i < 4; ++i)
		{
			for(int j = 0; j < 4; ++j)
			{
				assert(cast(bool)(uniimat4.col(i)*uniimat4.row(j)) == (i == j));
			}
		}
		assert(imat2(0,0,1,0).transpose()[1,0] == 1);
		assert(imat2(0,1,0,0).sub(0,1)[0,0] == 1);
		writeln(" access and slicing test passed");
	}
	{
		assert((uniimat3 + uniimat3*2)[1,1] == 3);
		assert(uniimat3*ivec3(1,2,3) == ivec3(1,2,3));
		assert((imat2(0,1,1,0)*imat2(0,-1,1,0))[0,0] == 1);
		writeln(" basic operations test passed");
	}
	{
		assert((uniimat3 + uniimat3*2)[1,1] == 3);
		assert(uniimat3*ivec3(1,2,3) == ivec3(1,2,3));
		assert((imat2(0,1,1,0)*imat2(0,-1,1,0))[0,0] == 1);
		writeln(" basic operations test passed");
	}
	{
		assert(uniimat4.det() == 1);
		assert(uniimat4.invert().det() == 1);
		writeln(" determinant and inverse test passed");
	}
	writeln("}");
}

import l4u.la.vec;

@system
struct mat(T, uint N, uint M = N)
{
public:
	T data[N*M];
	
	/* Constructors */
	this(S...)(S args)
	{
		import std.traits;
		static if(args.length == 1 && isPointer!(S[0]))
		{
			const T *p = args[0];
			for(int i = 0; i < M*N; ++i) 
			{
				data[i] = cast(T)p[i];
			}
		}
		else static if(args.length == 2 && isPointer!(S[0]) && isIntegral!(S[1]))
		{
			const T *p = args[0];
			int dy = args[1];
			for(int i = 0; i < M; ++i) 
			{
				for(int j = 0; j < N; ++j) 
				{
					data[i*N + j] = cast(T)p[(N + dy)*i + j];
				}
			}
		}
		else static if(args.length == 3 && isPointer!(S[0]) && isIntegral!(S[1]) && isIntegral!(S[2]))
		{
			const T *p = args[0];
			int dy = args[1];
			int dx = args[2];
			for(int i = 0; i < M; ++i) 
			{
				for(int j = 0; j < N; ++j) 
				{
					data[i*N + j] = cast(T)p[(dx*N + dy)*i + dx*j];
				}
			}
		}
		else static if(args.length == N*M)
		{
			foreach(i, ref comp; args)
			{
				data[i] = cast(T)comp;
			}
		}
		else static if(args.length == N)
		{
			foreach(i, ref v; args) 
			{
				for(int j = 0; j < M; ++j)
				{
					data[j*M + i] = cast(T)v[j];
				}
			}
		}
		else
		{
			static assert(args.length == N*M,"wrong number of arguments");
		}
	}
	
	this(S)(auto const ref mat!(S,N,M) m)
	{
		for(int i = 0; i < N*M; ++i) 
		{
			data[i] = cast(T)m.data[i];
		}
	}
	
	/* Assign */
	ref mat!(T,N,M) opAssign(S)(auto const ref mat!(S,N,M) m) 
	{
		for(int i = 0; i < N*M; ++i) {
			data[i] = cast(T)(m.data[i]);
		}
		return this;
	}
	
	/* Access operators */
	T opIndex()(uint x, uint y) const
	{
		return data[y*N + x];
	}
	
	ref T opIndex()(uint x, uint y)
	{
		return data[y*N + x];
	}
	
	T opIndex(S)(auto const ref vec!(S,2) v) const
	{
		return data[v.y*N + v.x];
	}
	
	ref T opIndex(S)(auto const ref vec!(S,2) v)
	{
		return data[v.y*N + v.x];
	}
	
	/* Transposed matrix */
	mat!(T,M,N) transpose() const
	{
		return mat!(T,M,N)(data.ptr,-M*N+1,N);
	}
	
	/* Rows and cols */
	vec!(T,N) row(int m) const
	{
		return vec!(T,N)(data.ptr + m*N);
	}
	vec!(T,M) col(int n) const
	{
		return vec!(T,M)(data.ptr + n, N);
	}
	
	/* Submatrix */
	static if(N > 1 && M > 1)
	{
		mat!(T,N-1,M-1) sub(int x, int y) const 
		{
			mat!(T,N-1,M-1) c;
			for(int ix = 0, jx = 0; ix < N; ++ix,++jx) 
			{
				if(ix == x) 
				{
					--jx;
					continue;
				}
				for(int iy = 0, jy = 0; iy < M; ++iy,++jy) 
				{
					if(iy == y)
					{
						--jy;
						continue;
					}
					c[jx,jy] = this[ix,iy];
				}
			}
			return c;
		}
	}
	
	/* Basic operations */
	 /* Addition */
	mat!(T,N,M) opBinary(string op : "+")(auto const ref mat!(T,N,M) b) const
	{
		mat!(T,N,M) c;
		c.data[] = data[] + b.data[];
		return c;
	}
	 /* Multiplication by constant */
	mat!(T,N,M) opBinary(string op : "*", S)(S s) const
	{
		mat!(T,N,M) c;
		c.data[] = s*data[];
		return c;
	}
	 /* Multiplication by vector */
	vec!(T,M) opBinary(string op : "*")(auto const ref vec!(T,N) v) const
	{
		vec!(T,M) c;
		for(int i = 0; i < M; ++i) 
		{
			c[i] = row(i)*v;
		}
		return c;
	}
	
	 /* Multiplication by vector from left */
	vec!(T,N) opBinaryRight(string op : "*")(auto const ref vec!(T,M) v) const
	{
		vec!(T,N) c;
		for(int i = 0; i < N; ++i) 
		{
			c[i] = v*m.col(i);
		}
		return c;
	}
	 /* Product of matrices */
	mat!(T,L,M) opBinary(string op : "*", uint L)(auto const ref mat!(T,N,L) b) const 
	{
		mat!(T,L,M) c;
		for(int i = 0; i < M; ++i) {
			for(int j = 0; j < L; ++j) {
				c[j,i] = row(i)*b.col(j);
			}
		}
		return c;
	}
	
	// Derivative operations
	mat!(T,N,M) opUnary(string op : "+")() const
	{
		return this;
	}
	mat!(T,N,M) opUnary(string op : "-")() const
	{
		return cast(T)(-1)*this;
	}
	mat!(T,N,M) opBinary(string op : "-")(auto const ref mat!(T,N,M) a) const
	{
		return this + (-a);
	}
	mat!(T,N,M) opBinaryRight(string op : "*", S)(S s) const
	{
		return this*s;
	}
	mat!(T,N,M) opBinary(string op : "/", S)(S s) const
	{
		return this*(cast(T)1/cast(T)s);
		// TODO: Division for integral matrices
	}

	/* Assign operations */
	ref mat!(T,N,M) opOpAssign(string op : "+")(auto const ref mat!(T,N,M) b)
	{
		return this = this + b;
	}
	ref mat!(T,N,M) opOpAssign(string op : "-")(auto const ref mat!(T,N,M) b)
	{
		return this = this + b;
	}
	ref mat!(T,N,M) opOpAssign(string op : "*", S)(S s)
	{
		return this = this*cast(T)s;
	}
	ref mat!(T,N,M) opOpAssign(string op : "/", S)(S s)
	{
		return this = this/cast(T)s;
	}
	
	static if(N == M)
	{
		static if(N > 1)
		{
			T cofactor(int x, int y) const
			{
				return (1 - 2*((x+y)%2))*sub(x,y).det();
			}
		}
		
		/* Determinant */
		T det() const
		{
			static if(N > 1) 
			{
				T c = cast(T)0;
				const int rc = 0;
				for(int i = 0; i < N; ++i)
				{
					c += this[i,rc]*cofactor(i,rc);
				}
				return c;
			} 
			else 
			{
				return data[0];
			}
		}
	
		/* Adjugate matrix */
		mat!(T,N,M) adj() const
		{
			static if(N > 1)
			{
				mat!(T,N,M) a;
				for(int ix = 0; ix < N; ++ix)
				{
					for(int iy = 0; iy < M; ++iy)
					{
						a[iy,ix] = cofactor(ix,iy);
					}
				}
				return a;
			}
			else
			{
				return mat!(T,N)(cast(T)1);
			}
		}
		
		/* Inverse matrix */
		mat!(T,N,M) invert() const
		{
			return adj()/det();
		}
	}
}

/* Short typenames */
alias dmat2 = mat!(double,2);
alias dmat3 = mat!(double,3);
alias dmat4 = mat!(double,4);
alias fmat2 = mat!(float,2);
alias fmat3 = mat!(float,3);
alias fmat4 = mat!(float,4);
alias imat2 = mat!(int,2);
alias imat3 = mat!(int,3);
alias imat4 = mat!(int,4);

alias mat2 = dmat2;
alias mat3 = dmat3;
alias mat4 = dmat4;

/* Constants */
const dmat2 nulldmat2 = dmat2(0,0,0,0);
const dmat3 nulldmat3 = dmat3(0,0,0,0,0,0,0,0,0);
const dmat4 nulldmat4 = dmat4(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
const fmat2 nullfmat2 = fmat2(0,0,0,0);
const fmat3 nullfmat3 = fmat3(0,0,0,0,0,0,0,0,0);
const fmat4 nullfmat4 = fmat4(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
const imat2 nullimat2 = imat2(0,0,0,0);
const imat3 nullimat3 = imat3(0,0,0,0,0,0,0,0,0);
const imat4 nullimat4 = imat4(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

const dmat2 unidmat2 = dmat2(1,0,0,1);
const dmat3 unidmat3 = dmat3(1,0,0,0,1,0,0,0,1);
const dmat4 unidmat4 = dmat4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);
const fmat2 unifmat2 = fmat2(1,0,0,1);
const fmat3 unifmat3 = fmat3(1,0,0,0,1,0,0,0,1);
const fmat4 unifmat4 = fmat4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);
const imat2 uniimat2 = imat2(1,0,0,1);
const imat3 uniimat3 = imat3(1,0,0,0,1,0,0,0,1);
const imat4 uniimat4 = imat4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);

const mat2 nullmat2 = nulldmat2;
const mat3 nullmat3 = nulldmat3;
const mat4 nullmat4 = nulldmat4;

const mat2 unimat2 = unidmat2;
const mat3 unimat3 = unidmat3;
const mat4 unimat4 = unidmat4;
