(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}




var _List_Nil = { $: 0 };
var _List_Nil_UNUSED = { $: '[]' };

function _List_Cons(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons_UNUSED(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log = F2(function(tag, value)
{
	return value;
});

var _Debug_log_UNUSED = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString(value)
{
	return '<internals>';
}

function _Debug_toString_UNUSED(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File !== 'undefined' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[36m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash_UNUSED(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.ak.L === region.aw.L)
	{
		return 'on line ' + region.ak.L;
	}
	return 'on lines ' + region.ak.L + ' through ' + region.aw.L;
}



// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	/**_UNUSED/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**_UNUSED/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**/
	if (typeof x.$ === 'undefined')
	//*/
	/**_UNUSED/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0 = 0;
var _Utils_Tuple0_UNUSED = { $: '#0' };

function _Utils_Tuple2(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2_UNUSED(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3_UNUSED(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr(c) { return c; }
function _Utils_chr_UNUSED(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return !isNaN(word)
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**_UNUSED/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap_UNUSED(value) { return { $: 0, a: value }; }
function _Json_unwrap_UNUSED(value) { return value.a; }

function _Json_wrap(value) { return value; }
function _Json_unwrap(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.bm,
		impl.bG,
		impl.bC,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**_UNUSED/, _Json_errorToString(result.a) /**/);
	var managers = {};
	var initPair = init(result.a);
	var model = initPair.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		var pair = A2(update, msg, model);
		stepper(model = pair.a, viewMetadata);
		_Platform_enqueueEffects(managers, pair.b, subscriptions(model));
	}

	_Platform_enqueueEffects(managers, initPair.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS
//
// Effects must be queued!
//
// Say your init contains a synchronous command, like Time.now or Time.here
//
//   - This will produce a batch of effects (FX_1)
//   - The synchronous task triggers the subsequent `update` call
//   - This will produce a batch of effects (FX_2)
//
// If we just start dispatching FX_2, subscriptions from FX_2 can be processed
// before subscriptions from FX_1. No good! Earlier versions of this code had
// this problem, leading to these reports:
//
//   https://github.com/elm/core/issues/980
//   https://github.com/elm/core/pull/981
//   https://github.com/elm/compiler/issues/1776
//
// The queue is necessary to avoid ordering issues for synchronous commands.


// Why use true/false here? Why not just check the length of the queue?
// The goal is to detect "are we currently dispatching effects?" If we
// are, we need to bail and let the ongoing while loop handle things.
//
// Now say the queue has 1 element. When we dequeue the final element,
// the queue will be empty, but we are still actively dispatching effects.
// So you could get queue jumping in a really tricky category of cases.
//
var _Platform_effectsQueue = [];
var _Platform_effectsActive = false;


function _Platform_enqueueEffects(managers, cmdBag, subBag)
{
	_Platform_effectsQueue.push({ p: managers, q: cmdBag, r: subBag });

	if (_Platform_effectsActive) return;

	_Platform_effectsActive = true;
	for (var fx; fx = _Platform_effectsQueue.shift(); )
	{
		_Platform_dispatchEffects(fx.p, fx.q, fx.r);
	}
	_Platform_effectsActive = false;
}


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				s: bag.n,
				t: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.t)
		{
			x = temp.s(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		u: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		u: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}
var $elm$core$Basics$EQ = 1;
var $elm$core$Basics$LT = 0;
var $elm$core$List$cons = _List_cons;
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (!node.$) {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === -2) {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Basics$GT = 2;
var $elm$core$Result$Err = function (a) {
	return {$: 1, a: a};
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 0, a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 2, a: a};
};
var $elm$core$Basics$False = 1;
var $elm$core$Basics$add = _Basics_add;
var $elm$core$Maybe$Just = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Maybe$Nothing = {$: 1};
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 0:
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 1) {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 1:
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 2:
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 0, a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 1, a: a};
};
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.b) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.d),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.d);
		} else {
			var treeLen = builder.b * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.e) : builder.e;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.b);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.d) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.d);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{e: nodeList, b: (len / $elm$core$Array$branchFactor) | 0, d: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = 0;
var $elm$core$Result$isOk = function (result) {
	if (!result.$) {
		return true;
	} else {
		return false;
	}
};
var $elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		A3(
			$elm$core$List$foldl,
			F2(
				function (_v0, obj) {
					var k = _v0.a;
					var v = _v0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(0),
			pairs));
};
var $elm$json$Json$Encode$string = _Json_wrap;
var $author$project$Ports$addPort = _Platform_outgoingPort(
	'addPort',
	function ($) {
		return $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'content',
					$elm$json$Json$Encode$string($.I)),
					_Utils_Tuple2(
					'filepath',
					$elm$json$Json$Encode$string($.J))
				]));
	});
var $elm$core$String$replace = F3(
	function (before, after, string) {
		return A2(
			$elm$core$String$join,
			after,
			A2($elm$core$String$split, before, string));
	});
var $author$project$Path$join = F2(
	function (separator, _v0) {
		var list = _v0;
		return A2($elm$core$String$join, separator, list);
	});
var $author$project$Path$toModulePath = $author$project$Path$join('.');
var $elm$core$String$length = _String_length;
var $elm$core$String$slice = _String_slice;
var $elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			$elm$core$String$slice,
			n,
			$elm$core$String$length(string),
			string);
	});
var $elm$core$String$fromList = _String_fromList;
var $elm$core$String$foldr = _String_foldr;
var $elm$core$String$toList = function (string) {
	return A3($elm$core$String$foldr, $elm$core$List$cons, _List_Nil, string);
};
var $elm$core$Char$toLower = _Char_toLower;
var $author$project$Path$lowercaseFirstLetter = function (str) {
	var _v0 = $elm$core$String$toList(str);
	if (_v0.b) {
		var first = _v0.a;
		var rest = _v0.b;
		return $elm$core$String$fromList(
			A2(
				$elm$core$List$cons,
				$elm$core$Char$toLower(first),
				rest));
	} else {
		return str;
	}
};
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						$elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var $author$project$Utils$Generate$singleLineRecord = F2(
	function (separator, properties) {
		if (!properties.b) {
			return '{}';
		} else {
			return '{ ' + (A2(
				$elm$core$String$join,
				', ',
				A2(
					$elm$core$List$map,
					function (_v1) {
						var k = _v1.a;
						var v = _v1.b;
						return _Utils_ap(
							k,
							_Utils_ap(separator, v));
					},
					properties)) + ' }');
		}
	});
var $author$project$Utils$Generate$singleLineRecordType = $author$project$Utils$Generate$singleLineRecord(' : ');
var $elm$core$String$append = _String_append;
var $elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var $elm$core$String$contains = _String_contains;
var $author$project$Path$isDynamic = $elm$core$String$contains('_');
var $author$project$Path$dynamicCount = function (_v0) {
	var list = _v0;
	return $elm$core$List$length(
		A2($elm$core$List$filter, $author$project$Path$isDynamic, list));
};
var $elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _v0 = f(mx);
		if (!_v0.$) {
			var x = _v0.a;
			return A2($elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var $elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			$elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var $author$project$Path$getDynamicParameter = function (str) {
	var _v0 = A2($elm$core$String$split, '_', str);
	if ((_v0.b && _v0.b.b) && (!_v0.b.b.b)) {
		var left = _v0.a;
		var _v1 = _v0.b;
		var right = _v1.a;
		return $elm$core$Maybe$Just(
			_Utils_Tuple2(left, right));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Path$toList = function (_v0) {
	var list = _v0;
	return list;
};
var $author$project$Path$toSingleLineParamRecord = F3(
	function (toRecord, toItem, path) {
		var count = $author$project$Path$dynamicCount(path);
		return (!count) ? '' : A2(
			$elm$core$String$append,
			' ',
			toRecord(
				A2(
					$elm$core$List$map,
					toItem,
					A2(
						$elm$core$List$filterMap,
						$author$project$Path$getDynamicParameter,
						$author$project$Path$toList(path)))));
	});
var $author$project$Path$optionalParams = A2(
	$author$project$Path$toSingleLineParamRecord,
	$author$project$Utils$Generate$singleLineRecordType,
	function (_v0) {
		var left = _v0.a;
		var right = _v0.b;
		return _Utils_Tuple2(
			$author$project$Path$lowercaseFirstLetter(left),
			right);
	});
var $author$project$Path$toParams = function (path) {
	var params = $author$project$Path$optionalParams(path);
	return (params === '') ? '()' : A2($elm$core$String$dropLeft, 1, params);
};
var $elm$core$String$trim = _String_trim;
var $author$project$Add$Application$create = function (path) {
	return $elm$core$String$trim(
		A3(
			$elm$core$String$replace,
			'{{params}}',
			$author$project$Path$toParams(path),
			A3(
				$elm$core$String$replace,
				'{{name}}',
				$author$project$Path$toModulePath(path),
				'\nmodule Pages.{{name}} exposing (Model, Msg, Params, page)\n\nimport Shared\nimport Spa.Document exposing (Document)\nimport Spa.Page as Page exposing (Page)\nimport Spa.Url as Url exposing (Url)\nimport UI exposing (Components)\nimport UI.Content exposing (Type(..))\n\n\npage : Page Params Model Msg\npage =\n    Page.application\n        { init = init\n        , update = update\n        , subscriptions = subscriptions\n        , view = view\n        , save = save\n        , load = load\n        }\n\n\n\n-- INIT\n\n\ntype alias Params =\n    {{params}}\n\n\ntype alias Model =\n    {}\n\n\ninit : Shared.Model -> Url Params -> ( Model, Cmd Msg )\ninit shared { params } =\n    ( {}, Cmd.none )\n\n\n\n-- UPDATE\n\n\ntype Msg\n    = ReplaceMe\n\n\nupdate : Msg -> Model -> ( Model, Cmd Msg )\nupdate msg model =\n    case msg of\n        ReplaceMe ->\n            ( model, Cmd.none )\n\n\nsave : Model -> Shared.Model -> Shared.Model\nsave model shared =\n    shared\n\n\nload : Shared.Model -> Model -> ( Model, Cmd Msg )\nload shared model =\n    ( model, Cmd.none )\n\n\nsubscriptions : Model -> Sub Msg\nsubscriptions model =\n    Sub.none\n\n\n\n-- VIEW\n\n\nview : Components Msg -> Model -> Document Msg\nview { t } model =\n    { title = "{{name}}"\n    , body = t Static "{{name}}"\n    }\n')));
};
var $author$project$Add$Element$create = function (path) {
	return $elm$core$String$trim(
		A3(
			$elm$core$String$replace,
			'{{params}}',
			$author$project$Path$toParams(path),
			A3(
				$elm$core$String$replace,
				'{{name}}',
				$author$project$Path$toModulePath(path),
				'\nmodule Pages.{{name}} exposing (Model, Msg, Params, page)\n\nimport Spa.Document exposing (Document)\nimport Spa.Page as Page exposing (Page)\nimport Spa.Url as Url exposing (Url)\nimport UI exposing (Components)\nimport UI.Content exposing (Type(..))\n\n\npage : Page Params Model Msg\npage =\n    Page.element\n        { init = init\n        , update = update\n        , view = view\n        , subscriptions = subscriptions\n        }\n\n\n\n-- INIT\n\n\ntype alias Params =\n    {{params}}\n\n\ntype alias Model =\n    {}\n\n\ninit : Url Params -> ( Model, Cmd Msg )\ninit { params } =\n    ( {}, Cmd.none )\n\n\n\n-- UPDATE\n\n\ntype Msg\n    = ReplaceMe\n\n\nupdate : Msg -> Model -> ( Model, Cmd Msg )\nupdate msg model =\n    case msg of\n        ReplaceMe ->\n            ( model, Cmd.none )\n\n\nsubscriptions : Model -> Sub Msg\nsubscriptions model =\n    Sub.none\n\n\n\n-- VIEW\n\n\nview : Components Msg -> Model -> Document Msg\nview { t } model =\n    { title = "{{name}}"\n    , body = t Static "{{name}}"\n    }\n')));
};
var $author$project$Add$Sandbox$create = function (path) {
	return $elm$core$String$trim(
		A3(
			$elm$core$String$replace,
			'{{params}}',
			$author$project$Path$toParams(path),
			A3(
				$elm$core$String$replace,
				'{{name}}',
				$author$project$Path$toModulePath(path),
				'\nmodule Pages.{{name}} exposing (Model, Msg, Params, page)\n\nimport Spa.Document exposing (Document)\nimport Spa.Page as Page exposing (Page)\nimport Spa.Url as Url exposing (Url)\nimport UI exposing (Components)\nimport UI.Content exposing (Type(..))\n\n\npage : Page Params Model Msg\npage =\n    Page.sandbox\n        { init = init\n        , update = update\n        , view = view\n        }\n\n\n\n-- INIT\n\n\ntype alias Params =\n    {{params}}\n\n\ntype alias Model =\n    {}\n\n\ninit : Url Params -> Model\ninit { params } =\n    {}\n\n\n\n-- UPDATE\n\n\ntype Msg\n    = ReplaceMe\n\n\nupdate : Msg -> Model -> Model\nupdate msg model =\n    case msg of\n        ReplaceMe ->\n            {}\n\n\n\n-- VIEW\n\n\nview : Components Msg -> Model -> Document Msg\nview { t } model =\n    { title = "{{name}}"\n    , body = t Static "{{name}}"\n    }\n')));
};
var $author$project$Add$Static$create = function (path) {
	return $elm$core$String$trim(
		A3(
			$elm$core$String$replace,
			'{{params}}',
			$author$project$Path$toParams(path),
			A3(
				$elm$core$String$replace,
				'{{name}}',
				$author$project$Path$toModulePath(path),
				'\nmodule Pages.{{name}} exposing (Model, Msg, Params, page)\n\nimport Spa.Document exposing (Document)\nimport Spa.Page as Page exposing (Page)\nimport Spa.Url as Url exposing (Url)\nimport UI exposing (Components)\nimport UI.Content exposing (Type(..))\n\n\npage : Page Params Model Msg\npage =\n    Page.static\n        { view = view\n        }\n\n\ntype alias Model =\n    Url Params\n\n\ntype alias Msg =\n    Never\n\n\n\n-- VIEW\n\n\ntype alias Params =\n    {{params}}\n\n\nview : Components Msg -> Url Params -> Document Msg\nview { t } { params } =\n    { title = "{{name}}"\n    , body = t Static "{{name}}"\n    }\n')));
};
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $author$project$Path$Internals = $elm$core$Basics$identity;
var $author$project$Path$fromModuleName = function (name) {
	return A2($elm$core$String$split, '.', name);
};
var $author$project$Path$toFilepath = function (_v0) {
	var list = _v0;
	return A2($elm$core$String$join, '/', list) + '.elm';
};
var $elm$json$Json$Encode$null = _Json_encodeNull;
var $author$project$Ports$uhhh = _Platform_outgoingPort(
	'uhhh',
	function ($) {
		return $elm$json$Json$Encode$null;
	});
var $author$project$Ports$add = function (_v0) {
	var name = _v0.V;
	var pageType = _v0.ah;
	var path = $author$project$Path$fromModuleName(name);
	var sendItBro = function (content) {
		return $author$project$Ports$addPort(
			{
				I: content,
				J: $author$project$Path$toFilepath(path)
			});
	};
	switch (pageType) {
		case 'static':
			return sendItBro(
				$author$project$Add$Static$create(path));
		case 'sandbox':
			return sendItBro(
				$author$project$Add$Sandbox$create(path));
		case 'element':
			return sendItBro(
				$author$project$Add$Element$create(path));
		case 'application':
			return sendItBro(
				$author$project$Add$Application$create(path));
		default:
			return $author$project$Ports$uhhh(0);
	}
};
var $elm$json$Json$Decode$andThen = _Json_andThen;
var $elm$json$Json$Encode$list = F2(
	function (func, entries) {
		return _Json_wrap(
			A3(
				$elm$core$List$foldl,
				_Json_addEntry(func),
				_Json_emptyArray(0),
				entries));
	});
var $author$project$Ports$buildPort = _Platform_outgoingPort(
	'buildPort',
	$elm$json$Json$Encode$list(
		function ($) {
			return $elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'content',
						$elm$json$Json$Encode$string($.I)),
						_Utils_Tuple2(
						'filepath',
						$elm$json$Json$Encode$string($.J))
					]));
		}));
var $elm$core$String$concat = function (strings) {
	return A2($elm$core$String$join, '', strings);
};
var $elm$core$String$lines = _String_lines;
var $elm$core$List$repeatHelp = F3(
	function (result, n, value) {
		repeatHelp:
		while (true) {
			if (n <= 0) {
				return result;
			} else {
				var $temp$result = A2($elm$core$List$cons, value, result),
					$temp$n = n - 1,
					$temp$value = value;
				result = $temp$result;
				n = $temp$n;
				value = $temp$value;
				continue repeatHelp;
			}
		}
	});
var $elm$core$List$repeat = F2(
	function (n, value) {
		return A3($elm$core$List$repeatHelp, _List_Nil, n, value);
	});
var $author$project$Utils$Generate$indent = F2(
	function (count, string) {
		return A2(
			$elm$core$String$join,
			'\n',
			A2(
				$elm$core$List$map,
				$elm$core$String$append(
					$elm$core$String$concat(
						A2($elm$core$List$repeat, count, '    '))),
				$elm$core$String$lines(string)));
	});
var $author$project$Utils$Generate$caseExpression = function (options) {
	var toBranch = function (_v1) {
		var value = _v1.a;
		var result = _v1.b;
		return A2(
			$elm$core$String$join,
			'\n',
			_List_fromArray(
				[
					value + ' ->',
					A2($author$project$Utils$Generate$indent, 1, result)
				]));
	};
	var _v0 = options._;
	if (!_v0.b) {
		return '';
	} else {
		return A2(
			$elm$core$String$join,
			'\n',
			_List_fromArray(
				[
					'case ' + (options.ao + ' of'),
					A2(
					$author$project$Utils$Generate$indent,
					1,
					A2(
						$elm$core$String$join,
						'\n\n',
						A2($elm$core$List$map, toBranch, options._)))
				]));
	}
};
var $author$project$Utils$Generate$function = function (options) {
	var _v0 = options.Y;
	if (!_v0.b) {
		return '';
	} else {
		return A2(
			$elm$core$String$join,
			'\n',
			_List_fromArray(
				[
					options.V + (' : ' + A2($elm$core$String$join, ' -> ', options.Y)),
					options.V + (' ' + (A3(
					$elm$core$List$foldl,
					F2(
						function (arg, str) {
							return str + (arg + ' ');
						}),
					'',
					options.ad) + '=')),
					A2($author$project$Utils$Generate$indent, 1, options.Z)
				]));
	}
};
var $author$project$Path$toTypeName = $author$project$Path$join('__');
var $author$project$Path$toVariableName = function (_v0) {
	var list = _v0;
	return A2(
		$elm$core$String$join,
		'__',
		A2(
			$elm$core$List$map,
			function (piece) {
				var _v1 = $author$project$Path$getDynamicParameter(piece);
				if (!_v1.$) {
					var _v2 = _v1.a;
					var left = _v2.a;
					var right = _v2.b;
					return $author$project$Path$lowercaseFirstLetter(left) + ('_' + $author$project$Path$lowercaseFirstLetter(right));
				} else {
					return $author$project$Path$lowercaseFirstLetter(piece);
				}
			},
			list));
};
var $author$project$Generators$Pages$pagesBundle = function (paths) {
	return $author$project$Utils$Generate$function(
		{
			Y: _List_fromArray(
				['Model', 'Bundle']),
			Z: $author$project$Utils$Generate$caseExpression(
				{
					_: A2(
						$elm$core$List$map,
						function (path) {
							var typeName = $author$project$Path$toTypeName(path);
							return _Utils_Tuple2(
								typeName + '__Model model',
								'pages.' + ($author$project$Path$toVariableName(path) + '.bundle model'));
						},
						paths),
					ao: 'bigModel'
				}),
			ad: _List_fromArray(
				['bigModel']),
			V: 'bundle'
		});
};
var $author$project$Generators$Pages$pagesImports = function (paths) {
	return A2(
		$elm$core$String$join,
		'\n',
		A2(
			$elm$core$List$map,
			$elm$core$Basics$append('import Pages.'),
			A2($elm$core$List$map, $author$project$Path$toModulePath, paths)));
};
var $author$project$Path$hasParams = function (path) {
	return $author$project$Path$dynamicCount(path) > 0;
};
var $author$project$Generators$Pages$pagesInit = function (paths) {
	return $author$project$Utils$Generate$function(
		{
			Y: _List_fromArray(
				['Route', 'Shared.Model', '( Model, Cmd Msg )']),
			Z: $author$project$Utils$Generate$caseExpression(
				{
					_: A2(
						$elm$core$List$map,
						function (path) {
							return _Utils_Tuple2(
								'Route.' + ($author$project$Path$toTypeName(path) + ($author$project$Path$hasParams(path) ? ' params' : '')),
								'pages.' + ($author$project$Path$toVariableName(path) + ('.init' + ($author$project$Path$hasParams(path) ? ' params' : ' ()'))));
						},
						paths),
					ao: 'route'
				}),
			ad: _List_fromArray(
				['route']),
			V: 'init'
		});
};
var $elm$core$List$append = F2(
	function (xs, ys) {
		if (!ys.b) {
			return xs;
		} else {
			return A3($elm$core$List$foldr, $elm$core$List$cons, ys, xs);
		}
	});
var $elm$core$List$concat = function (lists) {
	return A3($elm$core$List$foldr, $elm$core$List$append, _List_Nil, lists);
};
var $author$project$Utils$Generate$multilineThing = function (_v0) {
	var items = _v0.K;
	var prefixes = _v0.O;
	var suffix = _v0.P;
	return A2(
		$elm$core$String$join,
		'\n',
		$elm$core$List$concat(
			_List_fromArray(
				[
					_List_fromArray(
					[
						_Utils_ap(prefixes.q, items.q)
					]),
					A2(
					$elm$core$List$map,
					$elm$core$String$append(prefixes.t),
					items.t),
					suffix
				])));
};
var $author$project$Utils$Generate$multilineIndentedThing = function (options) {
	return A2(
		$elm$core$String$join,
		'\n',
		_List_fromArray(
			[
				options.aC,
				A2(
				$author$project$Utils$Generate$indent,
				1,
				$author$project$Utils$Generate$multilineThing(options))
			]));
};
var $author$project$Utils$Generate$customType = function (options) {
	var _v0 = options.bH;
	if (!_v0.b) {
		return '';
	} else {
		if (!_v0.b.b) {
			var first = _v0.a;
			return 'type ' + (options.V + (' = ' + first));
		} else {
			var first = _v0.a;
			var rest = _v0.b;
			return $author$project$Utils$Generate$multilineIndentedThing(
				{
					aC: 'type ' + options.V,
					K: {q: first, t: rest},
					O: {q: '= ', t: '| '},
					P: _List_Nil
				});
		}
	}
};
var $author$project$Generators$Pages$pagesCustomType = F2(
	function (name, paths) {
		return $author$project$Utils$Generate$customType(
			{
				V: name,
				bH: A2(
					$elm$core$List$map,
					function (path) {
						return $author$project$Path$toTypeName(path) + ('__' + (name + (' Pages.' + ($author$project$Path$toModulePath(path) + ('.' + name)))));
					},
					paths)
			});
	});
var $author$project$Generators$Pages$pagesModels = $author$project$Generators$Pages$pagesCustomType('Model');
var $author$project$Generators$Pages$pagesMsgs = $author$project$Generators$Pages$pagesCustomType('Msg');
var $author$project$Generators$Pages$pagesUpdate = function (paths) {
	return $author$project$Utils$Generate$function(
		{
			Y: _List_fromArray(
				['Msg', 'Model', '( Model, Cmd Msg )']),
			Z: $author$project$Utils$Generate$caseExpression(
				{
					_: function (cases) {
						return ($elm$core$List$length(paths) === 1) ? cases : _Utils_ap(
							cases,
							_List_fromArray(
								[
									_Utils_Tuple2('_', '( bigModel, Cmd.none )')
								]));
					}(
						A2(
							$elm$core$List$map,
							function (path) {
								var typeName = $author$project$Path$toTypeName(path);
								return _Utils_Tuple2(
									'( ' + (typeName + ('__Msg msg, ' + (typeName + '__Model model )'))),
									'pages.' + ($author$project$Path$toVariableName(path) + '.update msg model'));
							},
							paths)),
					ao: '( bigMsg, bigModel )'
				}),
			ad: _List_fromArray(
				['bigMsg bigModel']),
			V: 'update'
		});
};
var $author$project$Utils$Generate$record = F2(
	function (fromTuple, properties) {
		if (!properties.b) {
			return '{}';
		} else {
			if (!properties.b.b) {
				var first = properties.a;
				return '{ ' + (fromTuple(first) + ' }');
			} else {
				var first = properties.a;
				var rest = properties.b;
				return $author$project$Utils$Generate$multilineThing(
					{
						K: {
							q: fromTuple(first),
							t: A2($elm$core$List$map, fromTuple, rest)
						},
						O: {q: '{ ', t: ', '},
						P: _List_fromArray(
							['}'])
					});
			}
		}
	});
var $author$project$Utils$Generate$recordType = $author$project$Utils$Generate$record(
	function (_v0) {
		var key = _v0.a;
		var value = _v0.b;
		return key + (' : ' + value);
	});
var $author$project$Generators$Pages$pagesUpgradedTypes = function (paths) {
	return A2(
		$author$project$Utils$Generate$indent,
		1,
		$author$project$Utils$Generate$recordType(
			A2(
				$elm$core$List$map,
				function (path) {
					var name = 'Pages.' + $author$project$Path$toModulePath(path);
					return _Utils_Tuple2(
						$author$project$Path$toVariableName(path),
						'Upgraded ' + (name + ('.Params ' + (name + ('.Model ' + (name + '.Msg'))))));
				},
				paths)));
};
var $author$project$Utils$Generate$recordValue = $author$project$Utils$Generate$record(
	function (_v0) {
		var key = _v0.a;
		var value = _v0.b;
		return key + (' = ' + value);
	});
var $author$project$Generators$Pages$pagesUpgradedValues = function (paths) {
	return A2(
		$author$project$Utils$Generate$indent,
		1,
		$author$project$Utils$Generate$recordValue(
			A2(
				$elm$core$List$map,
				function (path) {
					return _Utils_Tuple2(
						$author$project$Path$toVariableName(path),
						'Pages.' + ($author$project$Path$toModulePath(path) + ('.page |> upgrade ' + ($author$project$Path$toTypeName(path) + ('__Model ' + ($author$project$Path$toTypeName(path) + '__Msg'))))));
				},
				paths)));
};
var $author$project$Generators$Pages$generate = function (paths) {
	return A3(
		$elm$core$String$replace,
		'{{pagesBundle}}',
		$author$project$Generators$Pages$pagesBundle(paths),
		A3(
			$elm$core$String$replace,
			'{{pagesUpdate}}',
			$author$project$Generators$Pages$pagesUpdate(paths),
			A3(
				$elm$core$String$replace,
				'{{pagesInit}}',
				$author$project$Generators$Pages$pagesInit(paths),
				A3(
					$elm$core$String$replace,
					'{{pagesUpgradedValues}}',
					$author$project$Generators$Pages$pagesUpgradedValues(paths),
					A3(
						$elm$core$String$replace,
						'{{pagesUpgradedTypes}}',
						$author$project$Generators$Pages$pagesUpgradedTypes(paths),
						A3(
							$elm$core$String$replace,
							'{{pagesMsgs}}',
							$author$project$Generators$Pages$pagesMsgs(paths),
							A3(
								$elm$core$String$replace,
								'{{pagesModels}}',
								$author$project$Generators$Pages$pagesModels(paths),
								A3(
									$elm$core$String$replace,
									'{{pagesImports}}',
									$author$project$Generators$Pages$pagesImports(paths),
									$elm$core$String$trim('\nmodule Spa.Generated.Pages exposing\n    ( Model\n    , Msg\n    , init\n    , load\n    , save\n    , subscriptions\n    , update\n    , view\n    )\n\nimport Color exposing (Color)\n{{pagesImports}}\nimport Shared\nimport Spa.Document as Document exposing (Document)\nimport Spa.Generated.Route as Route exposing (Route)\nimport Spa.Page exposing (Page)\nimport Spa.Url as Url\nimport Theme exposing (Theme)\nimport UI exposing (Components)\n\n\n-- TYPES\n\n\n{{pagesModels}}\n\n\n{{pagesMsgs}}\n\n\n\n-- INIT\n\n\n{{pagesInit}}\n\n\n\n-- UPDATE\n\n\n{{pagesUpdate}}\n\n\n\n-- BUNDLE - (view + subscriptions)\n\n\n{{pagesBundle}}\n\n\nview : Theme Color -> Model -> Document Msg\nview theme model =\n    (bundle model).view theme\n\n\nsubscriptions : Model -> Sub Msg\nsubscriptions model =\n    (bundle model).subscriptions ()\n\n\nsave : Model -> Shared.Model -> Shared.Model\nsave model =\n    (bundle model).save ()\n\n\nload : Model -> Shared.Model -> ( Model, Cmd Msg )\nload model =\n    (bundle model).load ()\n\n\n\n-- UPGRADING PAGES\n\n\ntype alias Upgraded params model msg =\n    { init : params -> Shared.Model -> ( Model, Cmd Msg )\n    , update : msg -> model -> ( Model, Cmd Msg )\n    , bundle : model -> Bundle\n    }\n\n\ntype alias Bundle =\n    { view : Theme Color -> Document Msg\n    , subscriptions : () -> Sub Msg\n    , save : () -> Shared.Model -> Shared.Model\n    , load : () -> Shared.Model -> ( Model, Cmd Msg )\n    }\n\n\nupgrade : (model -> Model) -> (msg -> Msg) -> Page params model msg -> Upgraded params model msg\nupgrade toModel toMsg page =\n    let\n        init_ params shared =\n            page.init shared (Url.create params shared.key shared.url) |> Tuple.mapBoth toModel (Cmd.map toMsg)\n\n        update_ msg model =\n            page.update msg model |> Tuple.mapBoth toModel (Cmd.map toMsg)\n\n        bundle_ model =\n            { view = \\theme -> page.view (UI.components theme) model |> Document.map toMsg\n            , subscriptions = \\() -> page.subscriptions model |> Sub.map toMsg\n            , save = \\() -> page.save model\n            , load = \\() -> load_ model\n            }\n\n        load_ model shared =\n            page.load shared model |> Tuple.mapBoth toModel (Cmd.map toMsg)\n    in\n    { init = init_\n    , update = update_\n    , bundle = bundle_\n    }\n\n\npages :\n{{pagesUpgradedTypes}}\npages =\n{{pagesUpgradedValues}}\n')))))))));
};
var $author$project$Generators$Route$routeCustomType = function (paths) {
	return $author$project$Utils$Generate$customType(
		{
			V: 'Route',
			bH: A2(
				$elm$core$List$map,
				function (path) {
					return _Utils_ap(
						$author$project$Path$toTypeName(path),
						$author$project$Path$optionalParams(path));
				},
				paths)
		});
};
var $author$project$Utils$Generate$list = function (values) {
	if (!values.b) {
		return '[]';
	} else {
		if (!values.b.b) {
			var first = values.a;
			return '[ ' + (first + ' ]');
		} else {
			var first = values.a;
			var rest = values.b;
			return $author$project$Utils$Generate$multilineThing(
				{
					K: {q: first, t: rest},
					O: {q: '[ ', t: ', '},
					P: _List_fromArray(
						[']'])
				});
		}
	}
};
var $author$project$Utils$Generate$singleLineRecordValue = $author$project$Utils$Generate$singleLineRecord(' = ');
var $elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var $elm$core$String$toLower = _String_toLower;
var $author$project$Path$sluggify = A2(
	$elm$core$Basics$composeR,
	$elm$core$String$toList,
	A2(
		$elm$core$Basics$composeR,
		$elm$core$List$map(
			function (_char) {
				return $elm$core$Char$isUpper(_char) ? $elm$core$String$fromList(
					_List_fromArray(
						[' ', _char])) : $elm$core$String$fromList(
					_List_fromArray(
						[_char]));
			}),
		A2(
			$elm$core$Basics$composeR,
			$elm$core$String$concat,
			A2(
				$elm$core$Basics$composeR,
				$elm$core$String$trim,
				A2(
					$elm$core$Basics$composeR,
					A2($elm$core$String$replace, ' ', '-'),
					$elm$core$String$toLower)))));
var $elm$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (n <= 0) {
				return list;
			} else {
				if (!list.b) {
					return list;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs;
					n = $temp$n;
					list = $temp$list;
					continue drop;
				}
			}
		}
	});
var $elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(x);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Path$stripEndingTop = function (list_) {
	return $elm$core$List$reverse(
		function (l) {
			return _Utils_eq(
				$elm$core$List$head(l),
				$elm$core$Maybe$Just('Top')) ? A2($elm$core$List$drop, 1, l) : l;
		}(
			$elm$core$List$reverse(list_)));
};
var $author$project$Path$toParser = function (_v0) {
	var list = _v0;
	var toUrlSegment = function (piece) {
		var _v4 = $author$project$Path$getDynamicParameter(piece);
		if (!_v4.$) {
			var _v5 = _v4.a;
			var right = _v5.b;
			return 'Parser.' + $elm$core$String$toLower(right);
		} else {
			return 'Parser.s \"' + ($author$project$Path$sluggify(piece) + '\"');
		}
	};
	var toUrlParser = function (list_) {
		return '(' + (A2(
			$elm$core$String$join,
			' </> ',
			A2(
				$elm$core$List$map,
				toUrlSegment,
				$author$project$Path$stripEndingTop(list_))) + ')');
	};
	var toStaticParser = function (list_) {
		return 'Parser.map ' + ($author$project$Path$toTypeName(list_) + (' ' + toUrlParser(list_)));
	};
	var toParamMap = A2(
		$author$project$Path$toSingleLineParamRecord,
		$author$project$Utils$Generate$singleLineRecordValue,
		function (_v3) {
			var left = _v3.a;
			return _Utils_Tuple2(
				$author$project$Path$lowercaseFirstLetter(left),
				$author$project$Path$lowercaseFirstLetter(left));
		});
	var dynamicParamsFn = function (list_) {
		return '\\' + (A2(
			$elm$core$String$join,
			' ',
			A2(
				$elm$core$List$map,
				function (_v2) {
					var left = _v2.a;
					return $author$project$Path$lowercaseFirstLetter(left);
				},
				A2($elm$core$List$filterMap, $author$project$Path$getDynamicParameter, list_))) + (' ->' + toParamMap(list_)));
	};
	var toDynamicParser = function (list_) {
		return A2(
			$elm$core$String$join,
			'\n',
			_List_fromArray(
				[
					toUrlParser(list_),
					'  |> Parser.map (' + (dynamicParamsFn(list_) + ')'),
					'  |> Parser.map ' + $author$project$Path$toTypeName(list_)
				]));
	};
	var count = $author$project$Path$dynamicCount(list);
	if ((list.b && (list.a === 'Top')) && (!list.b.b)) {
		return 'Parser.map Top Parser.top';
	} else {
		return (count > 0) ? toDynamicParser(list) : toStaticParser(list);
	}
};
var $author$project$Generators$Route$routeParsers = function (paths) {
	return A2(
		$author$project$Utils$Generate$indent,
		2,
		$author$project$Utils$Generate$list(
			A2($elm$core$List$map, $author$project$Path$toParser, paths)));
};
var $author$project$Path$toParamInputs = function (path) {
	var count = $author$project$Path$dynamicCount(path);
	return (!count) ? '' : (' { ' + (A2(
		$elm$core$String$join,
		', ',
		A2(
			$elm$core$List$map,
			function (_v0) {
				var left = _v0.a;
				return $author$project$Path$lowercaseFirstLetter(left);
			},
			A2(
				$elm$core$List$filterMap,
				$author$project$Path$getDynamicParameter,
				$author$project$Path$toList(path)))) + ' }'));
};
var $author$project$Path$toParamList = function (_v0) {
	var list = _v0;
	var helper = F2(
		function (piece, names) {
			var _v1 = $author$project$Path$getDynamicParameter(piece);
			if (!_v1.$) {
				var _v2 = _v1.a;
				var left = _v2.a;
				var right = _v2.b;
				return (right === 'Int') ? _Utils_ap(
					names,
					_List_fromArray(
						[
							'String.fromInt ' + $author$project$Path$lowercaseFirstLetter(left)
						])) : _Utils_ap(
					names,
					_List_fromArray(
						[
							$author$project$Path$lowercaseFirstLetter(left)
						]));
			} else {
				return _Utils_ap(
					names,
					_List_fromArray(
						[
							'\"' + ($author$project$Path$sluggify(piece) + '\"')
						]));
			}
		});
	return function (items) {
		return (!$elm$core$List$length(items)) ? '[]' : ('[ ' + (A2($elm$core$String$join, ', ', items) + ' ]'));
	}(
		A3(
			$elm$core$List$foldl,
			helper,
			_List_Nil,
			$author$project$Path$stripEndingTop(list)));
};
var $author$project$Generators$Route$routeSegments = function (paths) {
	if (!paths.b) {
		return '';
	} else {
		return A2(
			$author$project$Utils$Generate$indent,
			3,
			$author$project$Utils$Generate$caseExpression(
				{
					_: A2(
						$elm$core$List$map,
						function (path) {
							return _Utils_Tuple2(
								_Utils_ap(
									$author$project$Path$toTypeName(path),
									$author$project$Path$toParamInputs(path)),
								$author$project$Path$toParamList(path));
						},
						paths),
					ao: 'route'
				}));
	}
};
var $author$project$Generators$Route$generate = function (paths) {
	return A3(
		$elm$core$String$replace,
		'{{routeSegments}}',
		$author$project$Generators$Route$routeSegments(paths),
		A3(
			$elm$core$String$replace,
			'{{routeParsers}}',
			$author$project$Generators$Route$routeParsers(paths),
			A3(
				$elm$core$String$replace,
				'{{routeCustomType}}',
				$author$project$Generators$Route$routeCustomType(paths),
				$elm$core$String$trim('\nmodule Spa.Generated.Route exposing\n    ( Route(..)\n    , fromUrl\n    , toString\n    )\n\nimport Url exposing (Url)\nimport Url.Parser as Parser exposing ((</>), Parser)\n\n\n{{routeCustomType}}\n\n\nfromUrl : Url -> Maybe Route\nfromUrl =\n    Parser.parse routes\n\n\nroutes : Parser (Route -> a) a\nroutes =\n    Parser.oneOf\n{{routeParsers}}\n\n\ntoString : Route -> String\ntoString route =\n    let\n        segments : List String\n        segments =\n{{routeSegments}}\n    in\n    segments\n        |> String.join "/"\n        |> String.append "/"\n'))));
};
var $author$project$Ports$build = function (paths) {
	return $author$project$Ports$buildPort(
		_List_fromArray(
			[
				{
				I: $author$project$Generators$Route$generate(paths),
				J: 'Spa/Generated/Route.elm'
			},
				{
				I: $author$project$Generators$Pages$generate(paths),
				J: 'Spa/Generated/Pages.elm'
			}
			]));
};
var $elm$json$Json$Decode$field = _Json_decodeField;
var $elm$core$Basics$neq = _Utils_notEqual;
var $author$project$Path$fromFilepath = function (filepath) {
	return A2(
		$elm$core$List$filter,
		$elm$core$Basics$neq(''),
		A2(
			$elm$core$String$split,
			'/',
			A3($elm$core$String$replace, '.elm', '', filepath)));
};
var $elm$json$Json$Decode$list = _Json_decodeList;
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $elm$core$Platform$Sub$batch = _Platform_batch;
var $elm$core$Platform$Sub$none = $elm$core$Platform$Sub$batch(_List_Nil);
var $author$project$Path$last = function (list) {
	return $elm$core$List$head(
		$elm$core$List$reverse(list));
};
var $elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return $elm$core$Maybe$Just(
				f(value));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$core$Basics$not = _Basics_not;
var $elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var $author$project$Path$routingOrder = F2(
	function (_v0, _v1) {
		var list1 = _v0;
		var list2 = _v1;
		var endsInTop = A2(
			$elm$core$Basics$composeR,
			$author$project$Path$last,
			$elm$core$Basics$eq(
				$elm$core$Maybe$Just('Top')));
		var endsInDynamic = A2(
			$elm$core$Basics$composeR,
			$author$project$Path$last,
			A2(
				$elm$core$Basics$composeR,
				$elm$core$Maybe$map($author$project$Path$isDynamic),
				$elm$core$Maybe$withDefault(false)));
		return (_Utils_cmp(
			$elm$core$List$length(list1),
			$elm$core$List$length(list2)) < 0) ? 0 : ((_Utils_cmp(
			$elm$core$List$length(list1),
			$elm$core$List$length(list2)) > 0) ? 2 : ((endsInTop(list1) && (!endsInTop(list2))) ? 0 : (((!endsInTop(list1)) && endsInTop(list2)) ? 2 : (((!endsInDynamic(list1)) && endsInDynamic(list2)) ? 0 : ((endsInDynamic(list1) && (!endsInDynamic(list2))) ? 2 : 1)))));
	});
var $elm$core$List$sortWith = _List_sortWith;
var $elm$json$Json$Decode$string = _Json_decodeString;
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $elm$core$Platform$worker = _Platform_worker;
var $author$project$Main$main = $elm$core$Platform$worker(
	{
		bm: function (_v0) {
			var command = _v0.at;
			var filepaths = _v0.ay;
			var name = _v0.V;
			var pageType = _v0.ah;
			return _Utils_Tuple2(
				0,
				function () {
					switch (command) {
						case 'build':
							return $author$project$Ports$build(
								A2(
									$elm$core$List$sortWith,
									$author$project$Path$routingOrder,
									A2($elm$core$List$map, $author$project$Path$fromFilepath, filepaths)));
						case 'add':
							return $author$project$Ports$add(
								{V: name, ah: pageType});
						default:
							return $author$project$Ports$uhhh(0);
					}
				}());
		},
		bC: function (_v2) {
			return $elm$core$Platform$Sub$none;
		},
		bG: F2(
			function (_v3, model) {
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			})
	});
_Platform_export({'Main':{'init':$author$project$Main$main(
	A2(
		$elm$json$Json$Decode$andThen,
		function (pageType) {
			return A2(
				$elm$json$Json$Decode$andThen,
				function (name) {
					return A2(
						$elm$json$Json$Decode$andThen,
						function (filepaths) {
							return A2(
								$elm$json$Json$Decode$andThen,
								function (command) {
									return $elm$json$Json$Decode$succeed(
										{at: command, ay: filepaths, V: name, ah: pageType});
								},
								A2($elm$json$Json$Decode$field, 'command', $elm$json$Json$Decode$string));
						},
						A2(
							$elm$json$Json$Decode$field,
							'filepaths',
							$elm$json$Json$Decode$list($elm$json$Json$Decode$string)));
				},
				A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string));
		},
		A2($elm$json$Json$Decode$field, 'pageType', $elm$json$Json$Decode$string)))(0)}});}(this));