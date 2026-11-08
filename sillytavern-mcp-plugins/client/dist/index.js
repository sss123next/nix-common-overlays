import * as __WEBPACK_EXTERNAL_MODULE__power_user_js_3c7cfb8b__ from "../../../../power-user.js";
import * as __WEBPACK_EXTERNAL_MODULE__script_js_588e7203__ from "../../../../../script.js";
import * as __WEBPACK_EXTERNAL_MODULE__world_info_js_83198f57__ from "../../../../world-info.js";
import * as __WEBPACK_EXTERNAL_MODULE__instruct_mode_js_e7f3531a__ from "../../../../instruct-mode.js";
import * as __WEBPACK_EXTERNAL_MODULE__chats_js_c244506c__ from "../../../../chats.js";
import * as __WEBPACK_EXTERNAL_MODULE__openai_js_bf183548__ from "../../../../openai.js";
import * as __WEBPACK_EXTERNAL_MODULE__authors_note_js_59167e8d__ from "../../../../authors-note.js";
import * as __WEBPACK_EXTERNAL_MODULE__group_chats_js_678c16bd__ from "../../../../group-chats.js";
import * as __WEBPACK_EXTERNAL_MODULE__regex_engine_js_683beba0__ from "../../../regex/engine.js";
/******/ var __webpack_modules__ = ({

/***/ 199:
/***/ ((__unused_webpack_module, exports) => {



function _typeof(o) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (o) { return typeof o; } : function (o) { return o && "function" == typeof Symbol && o.constructor === Symbol && o !== Symbol.prototype ? "symbol" : typeof o; }, _typeof(o); }
function _classCallCheck(a, n) { if (!(a instanceof n)) throw new TypeError("Cannot call a class as a function"); }
function _defineProperties(e, r) { for (var t = 0; t < r.length; t++) { var o = r[t]; o.enumerable = o.enumerable || !1, o.configurable = !0, "value" in o && (o.writable = !0), Object.defineProperty(e, _toPropertyKey(o.key), o); } }
function _createClass(e, r, t) { return r && _defineProperties(e.prototype, r), t && _defineProperties(e, t), Object.defineProperty(e, "prototype", { writable: !1 }), e; }
function _toPropertyKey(t) { var i = _toPrimitive(t, "string"); return "symbol" == _typeof(i) ? i : i + ""; }
function _toPrimitive(t, r) { if ("object" != _typeof(t) || !t) return t; var e = t[Symbol.toPrimitive]; if (void 0 !== e) { var i = e.call(t, r || "default"); if ("object" != _typeof(i)) return i; throw new TypeError("@@toPrimitive must return a primitive value."); } return ("string" === r ? String : Number)(t); }
function _callSuper(t, o, e) { return o = _getPrototypeOf(o), _possibleConstructorReturn(t, _isNativeReflectConstruct() ? Reflect.construct(o, e || [], _getPrototypeOf(t).constructor) : o.apply(t, e)); }
function _possibleConstructorReturn(t, e) { if (e && ("object" == _typeof(e) || "function" == typeof e)) return e; if (void 0 !== e) throw new TypeError("Derived constructors may only return object or undefined"); return _assertThisInitialized(t); }
function _assertThisInitialized(e) { if (void 0 === e) throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); return e; }
function _inherits(t, e) { if ("function" != typeof e && null !== e) throw new TypeError("Super expression must either be null or a function"); t.prototype = Object.create(e && e.prototype, { constructor: { value: t, writable: !0, configurable: !0 } }), Object.defineProperty(t, "prototype", { writable: !1 }), e && _setPrototypeOf(t, e); }
function _wrapNativeSuper(t) { var r = "function" == typeof Map ? new Map() : void 0; return _wrapNativeSuper = function _wrapNativeSuper(t) { if (null === t || !_isNativeFunction(t)) return t; if ("function" != typeof t) throw new TypeError("Super expression must either be null or a function"); if (void 0 !== r) { if (r.has(t)) return r.get(t); r.set(t, Wrapper); } function Wrapper() { return _construct(t, arguments, _getPrototypeOf(this).constructor); } return Wrapper.prototype = Object.create(t.prototype, { constructor: { value: Wrapper, enumerable: !1, writable: !0, configurable: !0 } }), _setPrototypeOf(Wrapper, t); }, _wrapNativeSuper(t); }
function _construct(t, e, r) { if (_isNativeReflectConstruct()) return Reflect.construct.apply(null, arguments); var o = [null]; o.push.apply(o, e); var p = new (t.bind.apply(t, o))(); return r && _setPrototypeOf(p, r.prototype), p; }
function _isNativeReflectConstruct() { try { var t = !Boolean.prototype.valueOf.call(Reflect.construct(Boolean, [], function () {})); } catch (t) {} return (_isNativeReflectConstruct = function _isNativeReflectConstruct() { return !!t; })(); }
function _isNativeFunction(t) { try { return -1 !== Function.toString.call(t).indexOf("[native code]"); } catch (n) { return "function" == typeof t; } }
function _setPrototypeOf(t, e) { return _setPrototypeOf = Object.setPrototypeOf ? Object.setPrototypeOf.bind() : function (t, e) { return t.__proto__ = e, t; }, _setPrototypeOf(t, e); }
function _getPrototypeOf(t) { return _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf.bind() : function (t) { return t.__proto__ || Object.getPrototypeOf(t); }, _getPrototypeOf(t); }
Object.defineProperty(exports, "__esModule", ({
  value: true
}));
exports.JsonError = void 0;
var JsonError = /*#__PURE__*/function (_Error) {
  function JsonError(json) {
    var _this;
    _classCallCheck(this, JsonError);
    _this = _callSuper(this, JsonError, [json.error]);
    _this.data = json;
    return _this;
  }
  _inherits(JsonError, _Error);
  return _createClass(JsonError, [{
    key: "toString",
    value: function toString() {
      if (_typeof(this.data) === 'object' && this.data !== null) {
        return JSON.stringify(this.data, null, 2);
      }
      return String(this.data);
    }
  }]);
}(/*#__PURE__*/_wrapNativeSuper(Error));
exports.JsonError = JsonError;

/***/ }),

/***/ 182:
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {



function _typeof(o) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (o) { return typeof o; } : function (o) { return o && "function" == typeof Symbol && o.constructor === Symbol && o !== Symbol.prototype ? "symbol" : typeof o; }, _typeof(o); }
var _MCPClient;
function _createForOfIteratorHelper(r, e) { var t = "undefined" != typeof Symbol && r[Symbol.iterator] || r["@@iterator"]; if (!t) { if (Array.isArray(r) || (t = _unsupportedIterableToArray(r)) || e && r && "number" == typeof r.length) { t && (r = t); var _n = 0, F = function F() {}; return { s: F, n: function n() { return _n >= r.length ? { done: !0 } : { done: !1, value: r[_n++] }; }, e: function e(r) { throw r; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var o, a = !0, u = !1; return { s: function s() { t = t.call(r); }, n: function n() { var r = t.next(); return a = r.done, r; }, e: function e(r) { u = !0, o = r; }, f: function f() { try { a || null == t["return"] || t["return"](); } finally { if (u) throw o; } } }; }
function _unsupportedIterableToArray(r, a) { if (r) { if ("string" == typeof r) return _arrayLikeToArray(r, a); var t = {}.toString.call(r).slice(8, -1); return "Object" === t && r.constructor && (t = r.constructor.name), "Map" === t || "Set" === t ? Array.from(r) : "Arguments" === t || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(t) ? _arrayLikeToArray(r, a) : void 0; } }
function _arrayLikeToArray(r, a) { (null == a || a > r.length) && (a = r.length); for (var e = 0, n = Array(a); e < a; e++) n[e] = r[e]; return n; }
function _regeneratorRuntime() { "use strict"; /*! regenerator-runtime -- Copyright (c) 2014-present, Facebook, Inc. -- license (MIT): https://github.com/facebook/regenerator/blob/main/LICENSE */ _regeneratorRuntime = function _regeneratorRuntime() { return e; }; var t, e = {}, r = Object.prototype, n = r.hasOwnProperty, o = Object.defineProperty || function (t, e, r) { t[e] = r.value; }, i = "function" == typeof Symbol ? Symbol : {}, a = i.iterator || "@@iterator", c = i.asyncIterator || "@@asyncIterator", u = i.toStringTag || "@@toStringTag"; function define(t, e, r) { return Object.defineProperty(t, e, { value: r, enumerable: !0, configurable: !0, writable: !0 }), t[e]; } try { define({}, ""); } catch (t) { define = function define(t, e, r) { return t[e] = r; }; } function wrap(t, e, r, n) { var i = e && e.prototype instanceof Generator ? e : Generator, a = Object.create(i.prototype), c = new Context(n || []); return o(a, "_invoke", { value: makeInvokeMethod(t, r, c) }), a; } function tryCatch(t, e, r) { try { return { type: "normal", arg: t.call(e, r) }; } catch (t) { return { type: "throw", arg: t }; } } e.wrap = wrap; var h = "suspendedStart", l = "suspendedYield", f = "executing", s = "completed", y = {}; function Generator() {} function GeneratorFunction() {} function GeneratorFunctionPrototype() {} var p = {}; define(p, a, function () { return this; }); var d = Object.getPrototypeOf, v = d && d(d(values([]))); v && v !== r && n.call(v, a) && (p = v); var g = GeneratorFunctionPrototype.prototype = Generator.prototype = Object.create(p); function defineIteratorMethods(t) { ["next", "throw", "return"].forEach(function (e) { define(t, e, function (t) { return this._invoke(e, t); }); }); } function AsyncIterator(t, e) { function invoke(r, o, i, a) { var c = tryCatch(t[r], t, o); if ("throw" !== c.type) { var u = c.arg, h = u.value; return h && "object" == _typeof(h) && n.call(h, "__await") ? e.resolve(h.__await).then(function (t) { invoke("next", t, i, a); }, function (t) { invoke("throw", t, i, a); }) : e.resolve(h).then(function (t) { u.value = t, i(u); }, function (t) { return invoke("throw", t, i, a); }); } a(c.arg); } var r; o(this, "_invoke", { value: function value(t, n) { function callInvokeWithMethodAndArg() { return new e(function (e, r) { invoke(t, n, e, r); }); } return r = r ? r.then(callInvokeWithMethodAndArg, callInvokeWithMethodAndArg) : callInvokeWithMethodAndArg(); } }); } function makeInvokeMethod(e, r, n) { var o = h; return function (i, a) { if (o === f) throw Error("Generator is already running"); if (o === s) { if ("throw" === i) throw a; return { value: t, done: !0 }; } for (n.method = i, n.arg = a;;) { var c = n.delegate; if (c) { var u = maybeInvokeDelegate(c, n); if (u) { if (u === y) continue; return u; } } if ("next" === n.method) n.sent = n._sent = n.arg;else if ("throw" === n.method) { if (o === h) throw o = s, n.arg; n.dispatchException(n.arg); } else "return" === n.method && n.abrupt("return", n.arg); o = f; var p = tryCatch(e, r, n); if ("normal" === p.type) { if (o = n.done ? s : l, p.arg === y) continue; return { value: p.arg, done: n.done }; } "throw" === p.type && (o = s, n.method = "throw", n.arg = p.arg); } }; } function maybeInvokeDelegate(e, r) { var n = r.method, o = e.iterator[n]; if (o === t) return r.delegate = null, "throw" === n && e.iterator["return"] && (r.method = "return", r.arg = t, maybeInvokeDelegate(e, r), "throw" === r.method) || "return" !== n && (r.method = "throw", r.arg = new TypeError("The iterator does not provide a '" + n + "' method")), y; var i = tryCatch(o, e.iterator, r.arg); if ("throw" === i.type) return r.method = "throw", r.arg = i.arg, r.delegate = null, y; var a = i.arg; return a ? a.done ? (r[e.resultName] = a.value, r.next = e.nextLoc, "return" !== r.method && (r.method = "next", r.arg = t), r.delegate = null, y) : a : (r.method = "throw", r.arg = new TypeError("iterator result is not an object"), r.delegate = null, y); } function pushTryEntry(t) { var e = { tryLoc: t[0] }; 1 in t && (e.catchLoc = t[1]), 2 in t && (e.finallyLoc = t[2], e.afterLoc = t[3]), this.tryEntries.push(e); } function resetTryEntry(t) { var e = t.completion || {}; e.type = "normal", delete e.arg, t.completion = e; } function Context(t) { this.tryEntries = [{ tryLoc: "root" }], t.forEach(pushTryEntry, this), this.reset(!0); } function values(e) { if (e || "" === e) { var r = e[a]; if (r) return r.call(e); if ("function" == typeof e.next) return e; if (!isNaN(e.length)) { var o = -1, i = function next() { for (; ++o < e.length;) if (n.call(e, o)) return next.value = e[o], next.done = !1, next; return next.value = t, next.done = !0, next; }; return i.next = i; } } throw new TypeError(_typeof(e) + " is not iterable"); } return GeneratorFunction.prototype = GeneratorFunctionPrototype, o(g, "constructor", { value: GeneratorFunctionPrototype, configurable: !0 }), o(GeneratorFunctionPrototype, "constructor", { value: GeneratorFunction, configurable: !0 }), GeneratorFunction.displayName = define(GeneratorFunctionPrototype, u, "GeneratorFunction"), e.isGeneratorFunction = function (t) { var e = "function" == typeof t && t.constructor; return !!e && (e === GeneratorFunction || "GeneratorFunction" === (e.displayName || e.name)); }, e.mark = function (t) { return Object.setPrototypeOf ? Object.setPrototypeOf(t, GeneratorFunctionPrototype) : (t.__proto__ = GeneratorFunctionPrototype, define(t, u, "GeneratorFunction")), t.prototype = Object.create(g), t; }, e.awrap = function (t) { return { __await: t }; }, defineIteratorMethods(AsyncIterator.prototype), define(AsyncIterator.prototype, c, function () { return this; }), e.AsyncIterator = AsyncIterator, e.async = function (t, r, n, o, i) { void 0 === i && (i = Promise); var a = new AsyncIterator(wrap(t, r, n, o), i); return e.isGeneratorFunction(r) ? a : a.next().then(function (t) { return t.done ? t.value : a.next(); }); }, defineIteratorMethods(g), define(g, u, "Generator"), define(g, a, function () { return this; }), define(g, "toString", function () { return "[object Generator]"; }), e.keys = function (t) { var e = Object(t), r = []; for (var n in e) r.push(n); return r.reverse(), function next() { for (; r.length;) { var t = r.pop(); if (t in e) return next.value = t, next.done = !1, next; } return next.done = !0, next; }; }, e.values = values, Context.prototype = { constructor: Context, reset: function reset(e) { if (this.prev = 0, this.next = 0, this.sent = this._sent = t, this.done = !1, this.delegate = null, this.method = "next", this.arg = t, this.tryEntries.forEach(resetTryEntry), !e) for (var r in this) "t" === r.charAt(0) && n.call(this, r) && !isNaN(+r.slice(1)) && (this[r] = t); }, stop: function stop() { this.done = !0; var t = this.tryEntries[0].completion; if ("throw" === t.type) throw t.arg; return this.rval; }, dispatchException: function dispatchException(e) { if (this.done) throw e; var r = this; function handle(n, o) { return a.type = "throw", a.arg = e, r.next = n, o && (r.method = "next", r.arg = t), !!o; } for (var o = this.tryEntries.length - 1; o >= 0; --o) { var i = this.tryEntries[o], a = i.completion; if ("root" === i.tryLoc) return handle("end"); if (i.tryLoc <= this.prev) { var c = n.call(i, "catchLoc"), u = n.call(i, "finallyLoc"); if (c && u) { if (this.prev < i.catchLoc) return handle(i.catchLoc, !0); if (this.prev < i.finallyLoc) return handle(i.finallyLoc); } else if (c) { if (this.prev < i.catchLoc) return handle(i.catchLoc, !0); } else { if (!u) throw Error("try statement without catch or finally"); if (this.prev < i.finallyLoc) return handle(i.finallyLoc); } } } }, abrupt: function abrupt(t, e) { for (var r = this.tryEntries.length - 1; r >= 0; --r) { var o = this.tryEntries[r]; if (o.tryLoc <= this.prev && n.call(o, "finallyLoc") && this.prev < o.finallyLoc) { var i = o; break; } } i && ("break" === t || "continue" === t) && i.tryLoc <= e && e <= i.finallyLoc && (i = null); var a = i ? i.completion : {}; return a.type = t, a.arg = e, i ? (this.method = "next", this.next = i.finallyLoc, y) : this.complete(a); }, complete: function complete(t, e) { if ("throw" === t.type) throw t.arg; return "break" === t.type || "continue" === t.type ? this.next = t.arg : "return" === t.type ? (this.rval = this.arg = t.arg, this.method = "return", this.next = "end") : "normal" === t.type && e && (this.next = e), y; }, finish: function finish(t) { for (var e = this.tryEntries.length - 1; e >= 0; --e) { var r = this.tryEntries[e]; if (r.finallyLoc === t) return this.complete(r.completion, r.afterLoc), resetTryEntry(r), y; } }, "catch": function _catch(t) { for (var e = this.tryEntries.length - 1; e >= 0; --e) { var r = this.tryEntries[e]; if (r.tryLoc === t) { var n = r.completion; if ("throw" === n.type) { var o = n.arg; resetTryEntry(r); } return o; } } throw Error("illegal catch attempt"); }, delegateYield: function delegateYield(e, r, n) { return this.delegate = { iterator: values(e), resultName: r, nextLoc: n }, "next" === this.method && (this.arg = t), y; } }, e; }
function asyncGeneratorStep(n, t, e, r, o, a, c) { try { var i = n[a](c), u = i.value; } catch (n) { return void e(n); } i.done ? t(u) : Promise.resolve(u).then(r, o); }
function _asyncToGenerator(n) { return function () { var t = this, e = arguments; return new Promise(function (r, o) { var a = n.apply(t, e); function _next(n) { asyncGeneratorStep(a, r, o, _next, _throw, "next", n); } function _throw(n) { asyncGeneratorStep(a, r, o, _next, _throw, "throw", n); } _next(void 0); }); }; }
function _classCallCheck(a, n) { if (!(a instanceof n)) throw new TypeError("Cannot call a class as a function"); }
function _defineProperties(e, r) { for (var t = 0; t < r.length; t++) { var o = r[t]; o.enumerable = o.enumerable || !1, o.configurable = !0, "value" in o && (o.writable = !0), Object.defineProperty(e, _toPropertyKey(o.key), o); } }
function _createClass(e, r, t) { return r && _defineProperties(e.prototype, r), t && _defineProperties(e, t), Object.defineProperty(e, "prototype", { writable: !1 }), e; }
function _toPropertyKey(t) { var i = _toPrimitive(t, "string"); return "symbol" == _typeof(i) ? i : i + ""; }
function _toPrimitive(t, r) { if ("object" != _typeof(t) || !t) return t; var e = t[Symbol.toPrimitive]; if (void 0 !== e) { var i = e.call(t, r || "default"); if ("object" != _typeof(i)) return i; throw new TypeError("@@toPrimitive must return a primitive value."); } return ("string" === r ? String : Number)(t); }
function _assertClassBrand(e, t, n) { if ("function" == typeof e ? e === t : e.has(t)) return arguments.length < 3 ? t : n; throw new TypeError("Private element is not present on this object"); }
Object.defineProperty(exports, "__esModule", ({
  value: true
}));
exports.MCPClient = void 0;
var json_error_js_1 = __webpack_require__(199);
var PLUGIN_ID = 'mcp';
var MCPClient = /*#__PURE__*/function () {
  function MCPClient() {
    _classCallCheck(this, MCPClient);
  }
  return _createClass(MCPClient, null, [{
    key: "getServers",
    value: function () {
      var _getServers = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee() {
        var context, response, servers;
        return _regeneratorRuntime().wrap(function _callee$(_context) {
          while (1) switch (_context.prev = _context.next) {
            case 0:
              context = SillyTavern.getContext();
              _context.next = 3;
              return fetch("/api/plugins/".concat(PLUGIN_ID, "/servers"), {
                method: 'GET',
                headers: context.getRequestHeaders()
              });
            case 3:
              response = _context.sent;
              if (response.ok) {
                _context.next = 6;
                break;
              }
              return _context.abrupt("return", []);
            case 6:
              _context.next = 8;
              return response.json();
            case 8:
              servers = _context.sent;
              return _context.abrupt("return", servers);
            case 10:
            case "end":
              return _context.stop();
          }
        }, _callee);
      }));
      function getServers() {
        return _getServers.apply(this, arguments);
      }
      return getServers;
    }()
    /**
     * Fetches tools from an MCP server and registers them with the context.
     * @param serverName The name of the server to fetch tools from.
     * @returns Whether the tools were fetched and registered successfully.
     */
  }, {
    key: "registerTools",
    value: function registerTools(name) {
      var tools = _assertClassBrand(MCPClient, this, _serverTools)._.get(name);
      if (tools) {
        var enabledTools = tools.filter(function (tool) {
          return tool._enabled;
        });
        var _iterator = _createForOfIteratorHelper(enabledTools),
          _step;
        try {
          for (_iterator.s(); !(_step = _iterator.n()).done;) {
            var tool = _step.value;
            _assertClassBrand(MCPClient, this, _registerMcpTool).call(this, name, tool);
          }
        } catch (err) {
          _iterator.e(err);
        } finally {
          _iterator.f();
        }
        console.log("[MCPClient] Registered ".concat(enabledTools.length, " enabled tools for server \"").concat(name, "\""));
      }
    }
    /**
     * Registers an MCP tool with the context.
     * @param serverName The name of the server the tool belongs to.
     * @param tool The tool to register.
     */
  }, {
    key: "addServer",
    value: (
    /**
     * Adds a new MCP server configuration.
     * @param name The name of the server to add.
     * @param config The server configuration.
     * @returns Whether the server was added successfully.
     */
    function () {
      var _addServer = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee2(name, config) {
        var _context$extensionSet;
        var context, response, connectError;
        return _regeneratorRuntime().wrap(function _callee2$(_context2) {
          while (1) switch (_context2.prev = _context2.next) {
            case 0:
              context = SillyTavern.getContext();
              _context2.next = 3;
              return fetch("/api/plugins/".concat(PLUGIN_ID, "/servers"), {
                method: 'POST',
                headers: context.getRequestHeaders(),
                body: JSON.stringify({
                  name: name,
                  config: config
                })
              });
            case 3:
              response = _context2.sent;
              if (response.ok) {
                _context2.next = 6;
                break;
              }
              throw _assertClassBrand(MCPClient, this, _createUserFriendlyError).call(this, response, 'add MCP server');
            case 6:
              console.log("[MCPClient] Added server \"".concat(name, "\""));
              if (!((_context$extensionSet = context.extensionSettings.mcp) !== null && _context$extensionSet !== void 0 && _context$extensionSet.enabled)) {
                _context2.next = 22;
                break;
              }
              console.log("[MCPClient] Auto-starting server \"".concat(name, "\""));
              _context2.prev = 9;
              _context2.next = 12;
              return this.connect(name, config);
            case 12:
              _context2.next = 14;
              return _assertClassBrand(MCPClient, this, _fetchTools).call(this, name);
            case 14:
              this.registerTools(name);
              _context2.next = 22;
              break;
            case 17:
              _context2.prev = 17;
              _context2.t0 = _context2["catch"](9);
              connectError = new Error("Server \"".concat(name, "\" was added but failed to connect: ").concat(_context2.t0.message));
              connectError.isConnectError = true;
              throw connectError;
            case 22:
            case "end":
              return _context2.stop();
          }
        }, _callee2, this, [[9, 17]]);
      }));
      function addServer(_x, _x2) {
        return _addServer.apply(this, arguments);
      }
      return addServer;
    }()
    /**
     * Connects to an MCP server.
     * @param name The name of the server to connect to.
     * @param config The server configuration.
     * @returns Whether the connection was successful.
     */
    )
  }, {
    key: "connect",
    value: (function () {
      var _connect = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee3(name, config) {
        var context, response, error;
        return _regeneratorRuntime().wrap(function _callee3$(_context3) {
          while (1) switch (_context3.prev = _context3.next) {
            case 0:
              context = SillyTavern.getContext();
              _context3.next = 3;
              return fetch("/api/plugins/".concat(PLUGIN_ID, "/servers/").concat(name, "/start"), {
                method: 'POST',
                headers: context.getRequestHeaders(),
                body: JSON.stringify(config)
              });
            case 3:
              response = _context3.sent;
              if (response.ok) {
                _context3.next = 9;
                break;
              }
              _context3.next = 7;
              return response.json();
            case 7:
              error = _context3.sent;
              throw new Error(error.error || response.statusText);
            case 9:
              _assertClassBrand(MCPClient, this, _connectedServers)._.set(name, config);
              console.log("[MCPClient] Connected to server \"".concat(name, "\""));
            case 11:
            case "end":
              return _context3.stop();
          }
        }, _callee3, this);
      }));
      function connect(_x3, _x4) {
        return _connect.apply(this, arguments);
      }
      return connect;
    }()
    /**
     * Disconnects from an MCP server. Also unregisters all tools for this server.
     * @param name The name of the server to disconnect from.
     * @returns Whether the disconnection was successful.
     */
    )
  }, {
    key: "disconnect",
    value: (function () {
      var _disconnect = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee4(name) {
        var context, response, error;
        return _regeneratorRuntime().wrap(function _callee4$(_context4) {
          while (1) switch (_context4.prev = _context4.next) {
            case 0:
              context = SillyTavern.getContext();
              _context4.next = 3;
              return fetch("/api/plugins/".concat(PLUGIN_ID, "/servers/").concat(name, "/stop"), {
                method: 'POST',
                headers: context.getRequestHeaders()
              });
            case 3:
              response = _context4.sent;
              if (response.ok) {
                _context4.next = 9;
                break;
              }
              _context4.next = 7;
              return response.json();
            case 7:
              error = _context4.sent;
              throw new Error(error.error || response.statusText);
            case 9:
              _assertClassBrand(MCPClient, this, _connectedServers)._["delete"](name);
              console.log("[MCPClient] Disconnected from server \"".concat(name, "\""));
              // Unregister all tools for this server
              _assertClassBrand(MCPClient, this, _unregisterServerTools).call(this, name);
            case 12:
            case "end":
              return _context4.stop();
          }
        }, _callee4, this);
      }));
      function disconnect(_x5) {
        return _disconnect.apply(this, arguments);
      }
      return disconnect;
    }()
    /**
     * Unregisters all tools for a server from the context.
     * @param serverName The name of the server to unregister tools for.
     */
    )
  }, {
    key: "deleteServer",
    value: (
    /**
     * Deletes an MCP server configuration.
     * @param name The name of the server to delete.
     * @returns Whether the deletion was successful.
     */
    function () {
      var _deleteServer = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee5(name) {
        var context, response, error;
        return _regeneratorRuntime().wrap(function _callee5$(_context5) {
          while (1) switch (_context5.prev = _context5.next) {
            case 0:
              context = SillyTavern.getContext(); // First disconnect if connected
              if (!this.isConnected(name)) {
                _context5.next = 4;
                break;
              }
              _context5.next = 4;
              return this.disconnect(name);
            case 4:
              _context5.next = 6;
              return fetch("/api/plugins/".concat(PLUGIN_ID, "/servers/").concat(encodeURIComponent(name)), {
                method: 'DELETE',
                headers: context.getRequestHeaders()
              });
            case 6:
              response = _context5.sent;
              if (response.ok) {
                _context5.next = 12;
                break;
              }
              _context5.next = 10;
              return response.json();
            case 10:
              error = _context5.sent;
              throw new Error(error.error || response.statusText);
            case 12:
              console.log("[MCPClient] Deleted server \"".concat(name, "\""));
            case 13:
            case "end":
              return _context5.stop();
          }
        }, _callee5, this);
      }));
      function deleteServer(_x6) {
        return _deleteServer.apply(this, arguments);
      }
      return deleteServer;
    }()
    /**
     * Gets a list of connected MCP servers.
     * @returns A list of connected MCP server names.
     */
    )
  }, {
    key: "getConnectedServers",
    value: function getConnectedServers() {
      return Array.from(_assertClassBrand(MCPClient, this, _connectedServers)._.keys());
    }
    /**
     * Updates the list of disabled servers
     * @param disabledServers Array of server names that should be disabled
     * @returns Whether the update was successful
     */
  }, {
    key: "updateDisabledServers",
    value: (function () {
      var _updateDisabledServers = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee6(disabledServers) {
        var context, response, error, allServers, _iterator2, _step2, server, _context$extensionSet2, isDisabled, isConnected, shouldBeConnected;
        return _regeneratorRuntime().wrap(function _callee6$(_context6) {
          while (1) switch (_context6.prev = _context6.next) {
            case 0:
              context = SillyTavern.getContext();
              _context6.next = 3;
              return fetch("/api/plugins/".concat(PLUGIN_ID, "/servers/disabled"), {
                method: 'POST',
                headers: context.getRequestHeaders(),
                body: JSON.stringify({
                  disabledServers: disabledServers
                })
              });
            case 3:
              response = _context6.sent;
              if (response.ok) {
                _context6.next = 9;
                break;
              }
              _context6.next = 7;
              return response.json();
            case 7:
              error = _context6.sent;
              throw new Error(error.error || response.statusText);
            case 9:
              _context6.next = 11;
              return this.getServers();
            case 11:
              allServers = _context6.sent;
              _iterator2 = _createForOfIteratorHelper(allServers);
              _context6.prev = 13;
              _iterator2.s();
            case 15:
              if ((_step2 = _iterator2.n()).done) {
                _context6.next = 40;
                break;
              }
              server = _step2.value;
              _context6.prev = 17;
              isDisabled = disabledServers.includes(server.name);
              isConnected = this.isConnected(server.name);
              shouldBeConnected = !isDisabled && ((_context$extensionSet2 = context.extensionSettings.mcp) === null || _context$extensionSet2 === void 0 ? void 0 : _context$extensionSet2.enabled);
              if (!(!shouldBeConnected && isConnected)) {
                _context6.next = 26;
                break;
              }
              _context6.next = 24;
              return this.disconnect(server.name);
            case 24:
              _context6.next = 33;
              break;
            case 26:
              if (!(shouldBeConnected && !isConnected)) {
                _context6.next = 33;
                break;
              }
              _context6.next = 29;
              return this.connect(server.name, server.config);
            case 29:
              if (_assertClassBrand(MCPClient, this, _serverTools)._.has(server.name)) {
                _context6.next = 32;
                break;
              }
              _context6.next = 32;
              return _assertClassBrand(MCPClient, this, _fetchTools).call(this, server.name);
            case 32:
              this.registerTools(server.name);
            case 33:
              _context6.next = 38;
              break;
            case 35:
              _context6.prev = 35;
              _context6.t0 = _context6["catch"](17);
              throw _context6.t0;
            case 38:
              _context6.next = 15;
              break;
            case 40:
              _context6.next = 45;
              break;
            case 42:
              _context6.prev = 42;
              _context6.t1 = _context6["catch"](13);
              _iterator2.e(_context6.t1);
            case 45:
              _context6.prev = 45;
              _iterator2.f();
              return _context6.finish(45);
            case 48:
            case "end":
              return _context6.stop();
          }
        }, _callee6, this, [[13, 42, 45, 48], [17, 35]]);
      }));
      function updateDisabledServers(_x7) {
        return _updateDisabledServers.apply(this, arguments);
      }
      return updateDisabledServers;
    }()
    /**
     * Handles MCP tools and server connections
     * @param enabled Whether to enable or disable MCP functionality
     */
    )
  }, {
    key: "handleTools",
    value: (function () {
      var _handleTools = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee7(mcpEnabled) {
        var _context$extensionSet3;
        var context, errors, allServers, _iterator3, _step3, server, name, config, enabled, connectedServers, _iterator4, _step4, serverName;
        return _regeneratorRuntime().wrap(function _callee7$(_context7) {
          while (1) switch (_context7.prev = _context7.next) {
            case 0:
              context = SillyTavern.getContext();
              if (!(((_context$extensionSet3 = context.extensionSettings.mcp) === null || _context$extensionSet3 === void 0 ? void 0 : _context$extensionSet3.enabled) !== mcpEnabled)) {
                _context7.next = 3;
                break;
              }
              return _context7.abrupt("return");
            case 3:
              errors = [];
              if (!mcpEnabled) {
                _context7.next = 40;
                break;
              }
              _context7.next = 7;
              return this.getServers();
            case 7:
              allServers = _context7.sent;
              _iterator3 = _createForOfIteratorHelper(allServers);
              _context7.prev = 9;
              _iterator3.s();
            case 11:
              if ((_step3 = _iterator3.n()).done) {
                _context7.next = 30;
                break;
              }
              server = _step3.value;
              name = server.name, config = server.config, enabled = server.enabled; // Only connect to enabled servers
              if (!enabled) {
                _context7.next = 28;
                break;
              }
              _context7.prev = 15;
              if (this.isConnected(name)) {
                _context7.next = 19;
                break;
              }
              _context7.next = 19;
              return this.connect(name, config);
            case 19:
              if (_assertClassBrand(MCPClient, this, _serverTools)._.has(name)) {
                _context7.next = 22;
                break;
              }
              _context7.next = 22;
              return _assertClassBrand(MCPClient, this, _fetchTools).call(this, name);
            case 22:
              // Register tools
              this.registerTools(name);
              _context7.next = 28;
              break;
            case 25:
              _context7.prev = 25;
              _context7.t0 = _context7["catch"](15);
              errors.push(_context7.t0 instanceof Error ? _context7.t0 : new Error(String(_context7.t0)));
            case 28:
              _context7.next = 11;
              break;
            case 30:
              _context7.next = 35;
              break;
            case 32:
              _context7.prev = 32;
              _context7.t1 = _context7["catch"](9);
              _iterator3.e(_context7.t1);
            case 35:
              _context7.prev = 35;
              _iterator3.f();
              return _context7.finish(35);
            case 38:
              _context7.next = 64;
              break;
            case 40:
              // When disabling, disconnect servers and unregister tools
              connectedServers = this.getConnectedServers();
              _iterator4 = _createForOfIteratorHelper(connectedServers);
              _context7.prev = 42;
              _iterator4.s();
            case 44:
              if ((_step4 = _iterator4.n()).done) {
                _context7.next = 56;
                break;
              }
              serverName = _step4.value;
              _context7.prev = 46;
              _context7.next = 49;
              return this.disconnect(serverName);
            case 49:
              _context7.next = 54;
              break;
            case 51:
              _context7.prev = 51;
              _context7.t2 = _context7["catch"](46);
              errors.push(_context7.t2 instanceof Error ? _context7.t2 : new Error(String(_context7.t2)));
            case 54:
              _context7.next = 44;
              break;
            case 56:
              _context7.next = 61;
              break;
            case 58:
              _context7.prev = 58;
              _context7.t3 = _context7["catch"](42);
              _iterator4.e(_context7.t3);
            case 61:
              _context7.prev = 61;
              _iterator4.f();
              return _context7.finish(61);
            case 64:
              if (!(errors.length > 0)) {
                _context7.next = 66;
                break;
              }
              throw new Error("Failed to handle some servers: ".concat(errors.map(function (e) {
                return e.message;
              }).join(', ')));
            case 66:
            case "end":
              return _context7.stop();
          }
        }, _callee7, this, [[9, 32, 35, 38], [15, 25], [42, 58, 61, 64], [46, 51]]);
      }));
      function handleTools(_x8) {
        return _handleTools.apply(this, arguments);
      }
      return handleTools;
    }()
    /**
     * Checks if an MCP server is connected.
     * @param name The name of the server to check.
     * @returns Whether the server is connected.
     */
    )
  }, {
    key: "isConnected",
    value: function isConnected(name) {
      return _assertClassBrand(MCPClient, this, _connectedServers)._.has(name);
    }
    /**
     * Gets the tools for a specific server.
     * @param serverName The name of the server to get tools for.
     * @returns Array of tools for the server, or undefined if server has no tools.
     */
  }, {
    key: "getServerTools",
    value: (function () {
      var _getServerTools = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee8(serverName) {
        var cachedTools;
        return _regeneratorRuntime().wrap(function _callee8$(_context8) {
          while (1) switch (_context8.prev = _context8.next) {
            case 0:
              // First check in-memory cache
              cachedTools = _assertClassBrand(MCPClient, this, _serverTools)._.get(serverName);
              if (!cachedTools) {
                _context8.next = 3;
                break;
              }
              return _context8.abrupt("return", cachedTools);
            case 3:
              _context8.prev = 3;
              _context8.next = 6;
              return _assertClassBrand(MCPClient, this, _fetchTools).call(this, serverName);
            case 6:
              return _context8.abrupt("return", _assertClassBrand(MCPClient, this, _serverTools)._.get(serverName));
            case 9:
              _context8.prev = 9;
              _context8.t0 = _context8["catch"](3);
              return _context8.abrupt("return", undefined);
            case 12:
            case "end":
              return _context8.stop();
          }
        }, _callee8, this, [[3, 9]]);
      }));
      function getServerTools(_x9) {
        return _getServerTools.apply(this, arguments);
      }
      return getServerTools;
    }()
    /**
     * Updates the list of disabled tools for a server
     * @param serverName The name of the server
     * @param disabledTools Array of tool names that should be disabled
     * @returns Whether the update was successful
     */
    )
  }, {
    key: "updateDisabledTools",
    value: (function () {
      var _updateDisabledTools = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee9(serverName, disabledTools) {
        var _this = this;
        var context, response, error, tools;
        return _regeneratorRuntime().wrap(function _callee9$(_context9) {
          while (1) switch (_context9.prev = _context9.next) {
            case 0:
              context = SillyTavern.getContext();
              _context9.next = 3;
              return fetch("/api/plugins/".concat(PLUGIN_ID, "/servers/").concat(serverName, "/disabled-tools"), {
                method: 'POST',
                headers: context.getRequestHeaders(),
                body: JSON.stringify({
                  disabledTools: disabledTools
                })
              });
            case 3:
              response = _context9.sent;
              if (response.ok) {
                _context9.next = 9;
                break;
              }
              _context9.next = 7;
              return response.json();
            case 7:
              error = _context9.sent;
              throw new Error(error.error || response.statusText);
            case 9:
              // Update the tools' states in our cache
              tools = _assertClassBrand(MCPClient, this, _serverTools)._.get(serverName);
              if (tools) {
                tools.forEach(function (tool) {
                  var _context$extensionSet4;
                  var wasEnabled = tool._enabled;
                  tool._enabled = !disabledTools.includes(tool.name);
                  // If MCP is enabled, handle tool registration
                  if ((_context$extensionSet4 = context.extensionSettings.mcp) !== null && _context$extensionSet4 !== void 0 && _context$extensionSet4.enabled && _this.isConnected(serverName)) {
                    var toolId = "mcp_".concat(serverName, "_").concat(tool.name);
                    if (wasEnabled && !tool._enabled) {
                      // Tool was enabled but now disabled - unregister it
                      context.unregisterFunctionTool(toolId);
                    } else if (!wasEnabled && tool._enabled) {
                      // Tool was disabled but now enabled - register it
                      _assertClassBrand(MCPClient, _this, _registerMcpTool).call(_this, serverName, tool);
                    }
                  }
                });
              }
            case 11:
            case "end":
              return _context9.stop();
          }
        }, _callee9, this);
      }));
      function updateDisabledTools(_x10, _x11) {
        return _updateDisabledTools.apply(this, arguments);
      }
      return updateDisabledTools;
    }()
    /**
     * Calls a tool on an MCP server.
     * @param serverName The name of the server to call the tool on.
     * @param toolName The name of the tool to call.
     * @param args The arguments to pass to the tool.
     * @returns The result of the tool call.
     */
    )
  }, {
    key: "callTool",
    value: (function () {
      var _callTool = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee10(serverName, toolName, args) {
        var context, response, resp, data;
        return _regeneratorRuntime().wrap(function _callee10$(_context10) {
          while (1) switch (_context10.prev = _context10.next) {
            case 0:
              context = SillyTavern.getContext();
              if (this.isConnected(serverName)) {
                _context10.next = 3;
                break;
              }
              throw new Error("MCP server \"".concat(serverName, "\" is not connected."));
            case 3:
              _context10.next = 5;
              return fetch("/api/plugins/".concat(PLUGIN_ID, "/servers/").concat(serverName, "/call-tool"), {
                method: 'POST',
                body: JSON.stringify({
                  toolName: toolName,
                  arguments: args
                }),
                headers: context.getRequestHeaders()
              });
            case 5:
              response = _context10.sent;
              if (response.ok) {
                _context10.next = 11;
                break;
              }
              _context10.next = 9;
              return response.json();
            case 9:
              resp = _context10.sent;
              throw new json_error_js_1.JsonError(resp.data || resp.error || response.statusText);
            case 11:
              _context10.next = 13;
              return response.json();
            case 13:
              data = _context10.sent;
              console.log("[MCPClient] Successfully called tool \"".concat(toolName, "\" on server \"").concat(serverName, "\":"), data.result);
              return _context10.abrupt("return", data.result);
            case 16:
            case "end":
              return _context10.stop();
          }
        }, _callee10, this);
      }));
      function callTool(_x12, _x13, _x14) {
        return _callTool.apply(this, arguments);
      }
      return callTool;
    }()
    /**
     * Reloads tools for all connected MCP servers.
     * This will trigger a reload of tools on each server and update the local tool cache.
     * @returns Whether all servers were reloaded successfully.
     */
    )
  }, {
    key: "reloadAllTools",
    value: (function () {
      var _reloadAllTools = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee11() {
        var context, connectedServers, errors, _iterator5, _step5, server, serverName, response, error;
        return _regeneratorRuntime().wrap(function _callee11$(_context11) {
          while (1) switch (_context11.prev = _context11.next) {
            case 0:
              context = SillyTavern.getContext();
              _context11.next = 3;
              return this.getServers();
            case 3:
              connectedServers = _context11.sent;
              errors = [];
              _iterator5 = _createForOfIteratorHelper(connectedServers);
              _context11.prev = 6;
              _iterator5.s();
            case 8:
              if ((_step5 = _iterator5.n()).done) {
                _context11.next = 31;
                break;
              }
              server = _step5.value;
              serverName = server.name;
              _context11.prev = 11;
              _context11.next = 14;
              return fetch("/api/plugins/".concat(PLUGIN_ID, "/servers/").concat(serverName, "/reload-tools"), {
                method: 'POST',
                headers: context.getRequestHeaders()
              });
            case 14:
              response = _context11.sent;
              if (response.ok) {
                _context11.next = 20;
                break;
              }
              _context11.next = 18;
              return response.json();
            case 18:
              error = _context11.sent;
              throw new Error(error.error || response.statusText);
            case 20:
              _context11.next = 22;
              return _assertClassBrand(MCPClient, this, _fetchTools).call(this, serverName);
            case 22:
              // Re-register tools
              this.registerTools(serverName);
              console.log("[MCPClient] Successfully reloaded tools for server \"".concat(serverName, "\""));
              _context11.next = 29;
              break;
            case 26:
              _context11.prev = 26;
              _context11.t0 = _context11["catch"](11);
              errors.push(_context11.t0 instanceof Error ? _context11.t0 : new Error(String(_context11.t0)));
            case 29:
              _context11.next = 8;
              break;
            case 31:
              _context11.next = 36;
              break;
            case 33:
              _context11.prev = 33;
              _context11.t1 = _context11["catch"](6);
              _iterator5.e(_context11.t1);
            case 36:
              _context11.prev = 36;
              _iterator5.f();
              return _context11.finish(36);
            case 39:
              if (!(errors.length > 0)) {
                _context11.next = 41;
                break;
              }
              throw new Error("Failed to reload tools for some servers: ".concat(errors.map(function (e) {
                return e.message;
              }).join(', ')));
            case 41:
            case "end":
              return _context11.stop();
          }
        }, _callee11, this, [[6, 33, 36, 39], [11, 26]]);
      }));
      function reloadAllTools() {
        return _reloadAllTools.apply(this, arguments);
      }
      return reloadAllTools;
    }()
    /**
     * Opens the server settings UI.
     * @returns Whether the settings were opened successfully.
     */
    )
  }, {
    key: "openServerSettings",
    value: (function () {
      var _openServerSettings = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee12() {
        var context, response, error;
        return _regeneratorRuntime().wrap(function _callee12$(_context12) {
          while (1) switch (_context12.prev = _context12.next) {
            case 0:
              context = SillyTavern.getContext();
              _context12.next = 3;
              return fetch("/api/plugins/".concat(PLUGIN_ID, "/open-settings"), {
                method: 'POST',
                headers: context.getRequestHeaders()
              });
            case 3:
              response = _context12.sent;
              if (response.ok) {
                _context12.next = 9;
                break;
              }
              _context12.next = 7;
              return response.json();
            case 7:
              error = _context12.sent;
              throw new Error(error.error || response.statusText);
            case 9:
            case "end":
              return _context12.stop();
          }
        }, _callee12);
      }));
      function openServerSettings() {
        return _openServerSettings.apply(this, arguments);
      }
      return openServerSettings;
    }())
  }]);
}();
_MCPClient = MCPClient;
/**
 * Helper method to provide user-friendly error messages for common issues
 */
function _createUserFriendlyError(response, context) {
  var status = response.status;
  var statusText = response.statusText;
  if (status === 404) {
    return new Error("MCP Server plugin not found. Please install the SillyTavern MCP Server plugin first:\n" + "https://github.com/bmen25124/SillyTavern-MCP-Server\n\n" + "After installation, restart SillyTavern and try again.");
  }
  if (status === 500) {
    return new Error("MCP Server plugin error. The plugin may not be properly configured or started.\n" + "Check the SillyTavern console for more details.");
  }
  // For other errors, provide a generic but helpful message
  return new Error("Failed to ".concat(context, ". Error: ").concat(statusText, " (").concat(status, ")\n") + "Make sure the SillyTavern MCP Server plugin is installed and running.");
}
function _fetchTools(_x15) {
  return _fetchTools3.apply(this, arguments);
}
function _fetchTools3() {
  _fetchTools3 = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee15(serverName) {
    var context, response, error, data, tools;
    return _regeneratorRuntime().wrap(function _callee15$(_context15) {
      while (1) switch (_context15.prev = _context15.next) {
        case 0:
          context = SillyTavern.getContext();
          _context15.next = 3;
          return fetch("/api/plugins/".concat(PLUGIN_ID, "/servers/").concat(serverName, "/list-tools"), {
            method: 'GET',
            headers: context.getRequestHeaders()
          });
        case 3:
          response = _context15.sent;
          if (response.ok) {
            _context15.next = 9;
            break;
          }
          _context15.next = 7;
          return response.json();
        case 7:
          error = _context15.sent;
          throw new Error(error.error || response.statusText);
        case 9:
          _context15.next = 11;
          return response.json();
        case 11:
          data = _context15.sent;
          tools = Array.isArray(data) ? data : []; // Store tools in cache
          _assertClassBrand(_MCPClient, this, _serverTools)._.set(serverName, tools);
        case 14:
        case "end":
          return _context15.stop();
      }
    }, _callee15, this);
  }));
  return _fetchTools3.apply(this, arguments);
}
function _registerMcpTool(serverName, tool) {
  var _this2 = this;
  var context = SillyTavern.getContext();
  var toolId = "mcp_".concat(serverName, "_").concat(tool.name);
  context.registerFunctionTool({
    name: toolId,
    displayName: "".concat(serverName, ": ").concat(tool.name),
    description: tool.description || "Tool from MCP server \"".concat(serverName, "\""),
    parameters: tool.inputSchema || {
      type: 'object',
      properties: {}
    },
    action: function () {
      var _action = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee13(parameters) {
        return _regeneratorRuntime().wrap(function _callee13$(_context13) {
          while (1) switch (_context13.prev = _context13.next) {
            case 0:
              _context13.next = 2;
              return _this2.callTool(serverName, tool.name, parameters);
            case 2:
              return _context13.abrupt("return", _context13.sent);
            case 3:
            case "end":
              return _context13.stop();
          }
        }, _callee13);
      }));
      function action(_x16) {
        return _action.apply(this, arguments);
      }
      return action;
    }(),
    formatMessage: function () {
      var _formatMessage = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee14(parameters) {
        return _regeneratorRuntime().wrap(function _callee14$(_context14) {
          while (1) switch (_context14.prev = _context14.next) {
            case 0:
              return _context14.abrupt("return", "Calling MCP tool \"".concat(tool.name, "\" on server \"").concat(serverName, "\""));
            case 1:
            case "end":
              return _context14.stop();
          }
        }, _callee14);
      }));
      function formatMessage(_x17) {
        return _formatMessage.apply(this, arguments);
      }
      return formatMessage;
    }()
  });
}
function _unregisterServerTools(serverName) {
  var context = SillyTavern.getContext();
  var tools = _assertClassBrand(_MCPClient, this, _serverTools)._.get(serverName) || [];
  var _iterator6 = _createForOfIteratorHelper(tools),
    _step6;
  try {
    for (_iterator6.s(); !(_step6 = _iterator6.n()).done;) {
      var tool = _step6.value;
      var toolId = "mcp_".concat(serverName, "_").concat(tool.name);
      context.unregisterFunctionTool(toolId);
    }
  } catch (err) {
    _iterator6.e(err);
  } finally {
    _iterator6.f();
  }
  _assertClassBrand(_MCPClient, this, _serverTools)._["delete"](serverName);
  console.log("[MCPClient] Unregistered all tools for server \"".concat(serverName, "\""));
}
/**
 * A map of connected MCP servers.
 */
var _connectedServers = {
  _: new Map()
};
/**
 * A map of MCP server tools.
 */
var _serverTools = {
  _: new Map()
};
exports.MCPClient = MCPClient;

/***/ }),

/***/ 389:
/***/ ((__unused_webpack___webpack_module__, __webpack_exports__, __webpack_require__) => {

// ESM COMPAT FLAG
__webpack_require__.r(__webpack_exports__);

// EXPORTS
__webpack_require__.d(__webpack_exports__, {
  characters: () => (/* reexport */ external_script_js_namespaceObject.characters),
  depth_prompt_depth_default: () => (/* reexport */ external_script_js_namespaceObject.depth_prompt_depth_default),
  depth_prompt_role_default: () => (/* reexport */ external_script_js_namespaceObject.depth_prompt_role_default),
  extension_prompt_types: () => (/* reexport */ external_script_js_namespaceObject.extension_prompt_types),
  is_group_generating: () => (/* reexport */ external_group_chats_js_namespaceObject.is_group_generating),
  main_api: () => (/* reexport */ external_script_js_namespaceObject.main_api),
  name1: () => (/* reexport */ external_script_js_namespaceObject.name1),
  name2: () => (/* reexport */ external_script_js_namespaceObject.name2),
  persona_description_positions: () => (/* reexport */ external_power_user_js_namespaceObject.persona_description_positions),
  regex_placement: () => (/* reexport */ engine_js_namespaceObject.regex_placement),
  selected_group: () => (/* reexport */ external_group_chats_js_namespaceObject.selected_group),
  st_appendFileContent: () => (/* binding */ st_appendFileContent),
  st_baseChatReplace: () => (/* binding */ st_baseChatReplace),
  st_echo: () => (/* binding */ st_echo),
  st_formatInstructModeExamples: () => (/* binding */ st_formatInstructModeExamples),
  st_formatInstructModeSystemPrompt: () => (/* binding */ st_formatInstructModeSystemPrompt),
  st_formatWorldInfo: () => (/* binding */ st_formatWorldInfo),
  st_getAuthorNote: () => (/* binding */ st_getAuthorNote),
  st_getGroupDepthPrompts: () => (/* binding */ st_getGroupDepthPrompts),
  st_getMaxContextSize: () => (/* binding */ st_getMaxContextSize),
  st_getPromptPosition: () => (/* binding */ st_getPromptPosition),
  st_getPromptRole: () => (/* binding */ st_getPromptRole),
  st_getRegexedString: () => (/* binding */ st_getRegexedString),
  st_parseMesExamples: () => (/* binding */ st_parseMesExamples),
  st_prepareOpenAIMessages: () => (/* binding */ st_prepareOpenAIMessages),
  st_renderStoryString: () => (/* binding */ st_renderStoryString),
  st_runCommandCallback: () => (/* binding */ st_runCommandCallback),
  st_setOpenAIMessageExamples: () => (/* binding */ st_setOpenAIMessageExamples),
  st_setOpenAIMessages: () => (/* binding */ st_setOpenAIMessages),
  systemUserName: () => (/* reexport */ external_script_js_namespaceObject.systemUserName),
  system_avatar: () => (/* reexport */ external_script_js_namespaceObject.system_avatar),
  this_chid: () => (/* reexport */ external_script_js_namespaceObject.this_chid),
  wi_anchor_position: () => (/* reexport */ external_world_info_js_namespaceObject.wi_anchor_position),
  world_info_include_names: () => (/* reexport */ external_world_info_js_namespaceObject.world_info_include_names)
});

;// external "../../../../power-user.js"
var x = (y) => {
	var x = {}; __webpack_require__.d(x, y); return x
} 
var y = (x) => (() => (x))
const external_power_user_js_namespaceObject = x({ ["persona_description_positions"]: () => (__WEBPACK_EXTERNAL_MODULE__power_user_js_3c7cfb8b__.persona_description_positions), ["renderStoryString"]: () => (__WEBPACK_EXTERNAL_MODULE__power_user_js_3c7cfb8b__.renderStoryString) });
;// external "../../../../../script.js"
var external_script_js_x = (y) => {
	var x = {}; __webpack_require__.d(x, y); return x
} 
var external_script_js_y = (x) => (() => (x))
const external_script_js_namespaceObject = external_script_js_x({ ["baseChatReplace"]: () => (__WEBPACK_EXTERNAL_MODULE__script_js_588e7203__.baseChatReplace), ["characters"]: () => (__WEBPACK_EXTERNAL_MODULE__script_js_588e7203__.characters), ["chat_metadata"]: () => (__WEBPACK_EXTERNAL_MODULE__script_js_588e7203__.chat_metadata), ["depth_prompt_depth_default"]: () => (__WEBPACK_EXTERNAL_MODULE__script_js_588e7203__.depth_prompt_depth_default), ["depth_prompt_role_default"]: () => (__WEBPACK_EXTERNAL_MODULE__script_js_588e7203__.depth_prompt_role_default), ["extension_prompt_types"]: () => (__WEBPACK_EXTERNAL_MODULE__script_js_588e7203__.extension_prompt_types), ["getMaxContextSize"]: () => (__WEBPACK_EXTERNAL_MODULE__script_js_588e7203__.getMaxContextSize), ["main_api"]: () => (__WEBPACK_EXTERNAL_MODULE__script_js_588e7203__.main_api), ["name1"]: () => (__WEBPACK_EXTERNAL_MODULE__script_js_588e7203__.name1), ["name2"]: () => (__WEBPACK_EXTERNAL_MODULE__script_js_588e7203__.name2), ["parseMesExamples"]: () => (__WEBPACK_EXTERNAL_MODULE__script_js_588e7203__.parseMesExamples), ["systemUserName"]: () => (__WEBPACK_EXTERNAL_MODULE__script_js_588e7203__.systemUserName), ["system_avatar"]: () => (__WEBPACK_EXTERNAL_MODULE__script_js_588e7203__.system_avatar), ["this_chid"]: () => (__WEBPACK_EXTERNAL_MODULE__script_js_588e7203__.this_chid) });
;// external "../../../../world-info.js"
var external_world_info_js_x = (y) => {
	var x = {}; __webpack_require__.d(x, y); return x
} 
var external_world_info_js_y = (x) => (() => (x))
const external_world_info_js_namespaceObject = external_world_info_js_x({ ["wi_anchor_position"]: () => (__WEBPACK_EXTERNAL_MODULE__world_info_js_83198f57__.wi_anchor_position), ["world_info_include_names"]: () => (__WEBPACK_EXTERNAL_MODULE__world_info_js_83198f57__.world_info_include_names) });
;// external "../../../../instruct-mode.js"
var external_instruct_mode_js_x = (y) => {
	var x = {}; __webpack_require__.d(x, y); return x
} 
var external_instruct_mode_js_y = (x) => (() => (x))
const external_instruct_mode_js_namespaceObject = external_instruct_mode_js_x({ ["formatInstructModeExamples"]: () => (__WEBPACK_EXTERNAL_MODULE__instruct_mode_js_e7f3531a__.formatInstructModeExamples), ["formatInstructModeSystemPrompt"]: () => (__WEBPACK_EXTERNAL_MODULE__instruct_mode_js_e7f3531a__.formatInstructModeSystemPrompt) });
;// external "../../../../chats.js"
var external_chats_js_x = (y) => {
	var x = {}; __webpack_require__.d(x, y); return x
} 
var external_chats_js_y = (x) => (() => (x))
const external_chats_js_namespaceObject = external_chats_js_x({ ["appendFileContent"]: () => (__WEBPACK_EXTERNAL_MODULE__chats_js_c244506c__.appendFileContent) });
;// external "../../../../openai.js"
var external_openai_js_x = (y) => {
	var x = {}; __webpack_require__.d(x, y); return x
} 
var external_openai_js_y = (x) => (() => (x))
const external_openai_js_namespaceObject = external_openai_js_x({ ["formatWorldInfo"]: () => (__WEBPACK_EXTERNAL_MODULE__openai_js_bf183548__.formatWorldInfo), ["getPromptPosition"]: () => (__WEBPACK_EXTERNAL_MODULE__openai_js_bf183548__.getPromptPosition), ["getPromptRole"]: () => (__WEBPACK_EXTERNAL_MODULE__openai_js_bf183548__.getPromptRole), ["prepareOpenAIMessages"]: () => (__WEBPACK_EXTERNAL_MODULE__openai_js_bf183548__.prepareOpenAIMessages), ["setOpenAIMessageExamples"]: () => (__WEBPACK_EXTERNAL_MODULE__openai_js_bf183548__.setOpenAIMessageExamples), ["setOpenAIMessages"]: () => (__WEBPACK_EXTERNAL_MODULE__openai_js_bf183548__.setOpenAIMessages) });
;// external "../../../../authors-note.js"
var external_authors_note_js_x = (y) => {
	var x = {}; __webpack_require__.d(x, y); return x
} 
var external_authors_note_js_y = (x) => (() => (x))
const external_authors_note_js_namespaceObject = external_authors_note_js_x({ ["metadata_keys"]: () => (__WEBPACK_EXTERNAL_MODULE__authors_note_js_59167e8d__.metadata_keys) });
;// external "../../../../group-chats.js"
var external_group_chats_js_x = (y) => {
	var x = {}; __webpack_require__.d(x, y); return x
} 
var external_group_chats_js_y = (x) => (() => (x))
const external_group_chats_js_namespaceObject = external_group_chats_js_x({ ["getGroupDepthPrompts"]: () => (__WEBPACK_EXTERNAL_MODULE__group_chats_js_678c16bd__.getGroupDepthPrompts), ["is_group_generating"]: () => (__WEBPACK_EXTERNAL_MODULE__group_chats_js_678c16bd__.is_group_generating), ["selected_group"]: () => (__WEBPACK_EXTERNAL_MODULE__group_chats_js_678c16bd__.selected_group) });
;// external "../../../regex/engine.js"
var engine_js_x = (y) => {
	var x = {}; __webpack_require__.d(x, y); return x
} 
var engine_js_y = (x) => (() => (x))
const engine_js_namespaceObject = engine_js_x({ ["getRegexedString"]: () => (__WEBPACK_EXTERNAL_MODULE__regex_engine_js_683beba0__.getRegexedString), ["regex_placement"]: () => (__WEBPACK_EXTERNAL_MODULE__regex_engine_js_683beba0__.regex_placement) });
;// ./node_modules/sillytavern-utils-lib/dist/config.js
// @ts-ignore


// @ts-ignore

// @ts-ignore

// @ts-ignore


// @ts-ignore

// @ts-ignore

// @ts-ignore

async function st_runCommandCallback(command, ...args) {
    // @ts-ignore
    await SillyTavern.getContext().SlashCommandParser.commands[command].callback(...args);
}
/**
 * Sends an echo message using the SlashCommandParser's echo command.
 */
async function st_echo(severity, message) {
    await st_runCommandCallback('echo', { severity: severity }, message);
}
function st_getMaxContextSize(overrideResponseLength) {
    return (0,external_script_js_namespaceObject.getMaxContextSize)(overrideResponseLength);
}
function st_parseMesExamples(examplesStr, isInstruct) {
    return (0,external_script_js_namespaceObject.parseMesExamples)(examplesStr, isInstruct);
}
function st_baseChatReplace(value, name1, name2) {
    return (0,external_script_js_namespaceObject.baseChatReplace)(value, name1, name2);
}
function st_formatInstructModeExamples(mesExamplesArray, name1, name2) {
    return (0,external_instruct_mode_js_namespaceObject.formatInstructModeExamples)(mesExamplesArray, name1, name2);
}
function st_formatInstructModeSystemPrompt(systemPrompt, customInstruct) {
    return (0,external_instruct_mode_js_namespaceObject.formatInstructModeSystemPrompt)(systemPrompt, customInstruct);
}
function st_renderStoryString(params, { customStoryString, customInstructSettings, } = {}) {
    return (0,external_power_user_js_namespaceObject.renderStoryString)(params, { customStoryString, customInstructSettings });
}
function st_getPromptRole(role) {
    return (0,external_openai_js_namespaceObject.getPromptRole)(role);
}
function st_getAuthorNote() {
    return {
        prompt: external_script_js_namespaceObject.chat_metadata[external_authors_note_js_namespaceObject.metadata_keys.prompt],
        interval: external_script_js_namespaceObject.chat_metadata[external_authors_note_js_namespaceObject.metadata_keys.interval],
        position: external_script_js_namespaceObject.chat_metadata[external_authors_note_js_namespaceObject.metadata_keys.position],
        depth: external_script_js_namespaceObject.chat_metadata[external_authors_note_js_namespaceObject.metadata_keys.depth],
        role: external_script_js_namespaceObject.chat_metadata[external_authors_note_js_namespaceObject.metadata_keys.role],
    };
}
function st_getGroupDepthPrompts(groupId, characterId) {
    return (0,external_group_chats_js_namespaceObject.getGroupDepthPrompts)(groupId, characterId);
}
function st_prepareOpenAIMessages({ name2, charDescription, charPersonality, Scenario, worldInfoBefore, worldInfoAfter, bias, type, quietPrompt, quietImage, extensionPrompts, cyclePrompt, systemPromptOverride, jailbreakPromptOverride, personaDescription, messages, messageExamples, }, dryRun) {
    return (0,external_openai_js_namespaceObject.prepareOpenAIMessages)({
        name2,
        charDescription,
        charPersonality,
        Scenario,
        worldInfoBefore,
        worldInfoAfter,
        bias,
        type,
        quietPrompt,
        quietImage,
        cyclePrompt,
        systemPromptOverride,
        jailbreakPromptOverride,
        personaDescription,
        extensionPrompts,
        messages,
        messageExamples,
    }, dryRun);
}
function st_setOpenAIMessages(chat) {
    return (0,external_openai_js_namespaceObject.setOpenAIMessages)(chat);
}
function st_setOpenAIMessageExamples(mesExamplesArray) {
    return (0,external_openai_js_namespaceObject.setOpenAIMessageExamples)(mesExamplesArray);
}
function st_getRegexedString(rawString, placement, { characterOverride, isMarkdown, isPrompt, isEdit, depth, }) {
    return (0,engine_js_namespaceObject.getRegexedString)(rawString, placement, { characterOverride, isMarkdown, isPrompt, isEdit, depth });
}
async function st_appendFileContent(message, messageText) {
    return await (0,external_chats_js_namespaceObject.appendFileContent)(message, messageText);
}
function st_formatWorldInfo(value, { wiFormat, } = {}) {
    return (0,external_openai_js_namespaceObject.formatWorldInfo)(value, { wiFormat });
}
function st_getPromptPosition(position) {
    return (0,external_openai_js_namespaceObject.getPromptPosition)(position);
}

//# sourceMappingURL=config.js.map

/***/ }),

/***/ 886:
/***/ ((__unused_webpack___webpack_module__, __webpack_exports__, __webpack_require__) => {

__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   EventNames: () => (/* binding */ EventNames)
/* harmony export */ });
var EventNames;
(function (EventNames) {
    EventNames["APP_READY"] = "app_ready";
    EventNames["EXTRAS_CONNECTED"] = "extras_connected";
    EventNames["MESSAGE_SWIPED"] = "message_swiped";
    EventNames["MESSAGE_SENT"] = "message_sent";
    EventNames["MESSAGE_RECEIVED"] = "message_received";
    EventNames["MESSAGE_EDITED"] = "message_edited";
    EventNames["MESSAGE_DELETED"] = "message_deleted";
    EventNames["MESSAGE_UPDATED"] = "message_updated";
    EventNames["MESSAGE_FILE_EMBEDDED"] = "message_file_embedded";
    EventNames["MORE_MESSAGES_LOADED"] = "more_messages_loaded";
    EventNames["IMPERSONATE_READY"] = "impersonate_ready";
    EventNames["CHAT_CHANGED"] = "chat_id_changed";
    EventNames["GENERATION_AFTER_COMMANDS"] = "GENERATION_AFTER_COMMANDS";
    EventNames["GENERATION_STARTED"] = "generation_started";
    EventNames["GENERATION_STOPPED"] = "generation_stopped";
    EventNames["GENERATION_ENDED"] = "generation_ended";
    EventNames["EXTENSIONS_FIRST_LOAD"] = "extensions_first_load";
    EventNames["EXTENSION_SETTINGS_LOADED"] = "extension_settings_loaded";
    EventNames["SETTINGS_LOADED"] = "settings_loaded";
    EventNames["SETTINGS_UPDATED"] = "settings_updated";
    EventNames["GROUP_UPDATED"] = "group_updated";
    EventNames["MOVABLE_PANELS_RESET"] = "movable_panels_reset";
    EventNames["SETTINGS_LOADED_BEFORE"] = "settings_loaded_before";
    EventNames["SETTINGS_LOADED_AFTER"] = "settings_loaded_after";
    EventNames["CHATCOMPLETION_SOURCE_CHANGED"] = "chatcompletion_source_changed";
    EventNames["CHATCOMPLETION_MODEL_CHANGED"] = "chatcompletion_model_changed";
    EventNames["OAI_PRESET_CHANGED_BEFORE"] = "oai_preset_changed_before";
    EventNames["OAI_PRESET_CHANGED_AFTER"] = "oai_preset_changed_after";
    EventNames["OAI_PRESET_EXPORT_READY"] = "oai_preset_export_ready";
    EventNames["OAI_PRESET_IMPORT_READY"] = "oai_preset_import_ready";
    EventNames["WORLDINFO_SETTINGS_UPDATED"] = "worldinfo_settings_updated";
    EventNames["WORLDINFO_UPDATED"] = "worldinfo_updated";
    EventNames["CHARACTER_EDITED"] = "character_edited";
    EventNames["CHARACTER_PAGE_LOADED"] = "character_page_loaded";
    EventNames["CHARACTER_GROUP_OVERLAY_STATE_CHANGE_BEFORE"] = "character_group_overlay_state_change_before";
    EventNames["CHARACTER_GROUP_OVERLAY_STATE_CHANGE_AFTER"] = "character_group_overlay_state_change_after";
    EventNames["USER_MESSAGE_RENDERED"] = "user_message_rendered";
    EventNames["CHARACTER_MESSAGE_RENDERED"] = "character_message_rendered";
    EventNames["FORCE_SET_BACKGROUND"] = "force_set_background";
    EventNames["CHAT_DELETED"] = "chat_deleted";
    EventNames["CHAT_CREATED"] = "chat_created";
    EventNames["GROUP_CHAT_DELETED"] = "group_chat_deleted";
    EventNames["GROUP_CHAT_CREATED"] = "group_chat_created";
    EventNames["GENERATE_BEFORE_COMBINE_PROMPTS"] = "generate_before_combine_prompts";
    EventNames["GENERATE_AFTER_COMBINE_PROMPTS"] = "generate_after_combine_prompts";
    EventNames["GENERATE_AFTER_DATA"] = "generate_after_data";
    EventNames["GROUP_MEMBER_DRAFTED"] = "group_member_drafted";
    EventNames["GROUP_WRAPPER_STARTED"] = "group_wrapper_started";
    EventNames["GROUP_WRAPPER_FINISHED"] = "group_wrapper_finished";
    EventNames["WORLD_INFO_ACTIVATED"] = "world_info_activated";
    EventNames["TEXT_COMPLETION_SETTINGS_READY"] = "text_completion_settings_ready";
    EventNames["CHAT_COMPLETION_SETTINGS_READY"] = "chat_completion_settings_ready";
    EventNames["CHAT_COMPLETION_PROMPT_READY"] = "chat_completion_prompt_ready";
    EventNames["CHARACTER_FIRST_MESSAGE_SELECTED"] = "character_first_message_selected";
    // TODO: Naming convention is inconsistent with other events
    EventNames["CHARACTER_DELETED"] = "characterDeleted";
    EventNames["CHARACTER_DUPLICATED"] = "character_duplicated";
    EventNames["CHARACTER_RENAMED"] = "character_renamed";
    /** @deprecated The event is aliased to STREAM_TOKEN_RECEIVED. */
    EventNames["SMOOTH_STREAM_TOKEN_RECEIVED"] = "stream_token_received";
    EventNames["STREAM_TOKEN_RECEIVED"] = "stream_token_received";
    EventNames["STREAM_REASONING_DONE"] = "stream_reasoning_done";
    EventNames["FILE_ATTACHMENT_DELETED"] = "file_attachment_deleted";
    EventNames["WORLDINFO_FORCE_ACTIVATE"] = "worldinfo_force_activate";
    EventNames["OPEN_CHARACTER_LIBRARY"] = "open_character_library";
    EventNames["ONLINE_STATUS_CHANGED"] = "online_status_changed";
    EventNames["IMAGE_SWIPED"] = "image_swiped";
    EventNames["CONNECTION_PROFILE_LOADED"] = "connection_profile_loaded";
    EventNames["TOOL_CALLS_PERFORMED"] = "tool_calls_performed";
    EventNames["TOOL_CALLS_RENDERED"] = "tool_calls_rendered";
})(EventNames || (EventNames = {}));
//# sourceMappingURL=index.js.map

/***/ }),

/***/ 452:
/***/ ((__unused_webpack___webpack_module__, __webpack_exports__, __webpack_require__) => {

__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   POPUP_RESULT: () => (/* binding */ POPUP_RESULT),
/* harmony export */   POPUP_TYPE: () => (/* binding */ POPUP_TYPE)
/* harmony export */ });
var POPUP_TYPE;
(function (POPUP_TYPE) {
    POPUP_TYPE[POPUP_TYPE["TEXT"] = 1] = "TEXT";
    POPUP_TYPE[POPUP_TYPE["CONFIRM"] = 2] = "CONFIRM";
    POPUP_TYPE[POPUP_TYPE["INPUT"] = 3] = "INPUT";
    POPUP_TYPE[POPUP_TYPE["DISPLAY"] = 4] = "DISPLAY";
})(POPUP_TYPE || (POPUP_TYPE = {}));
var POPUP_RESULT;
(function (POPUP_RESULT) {
    POPUP_RESULT[POPUP_RESULT["AFFIRMATIVE"] = 1] = "AFFIRMATIVE";
    POPUP_RESULT[POPUP_RESULT["NEGATIVE"] = 0] = "NEGATIVE";
    // @ts-ignore
    POPUP_RESULT[POPUP_RESULT["CANCELLED"] = null] = "CANCELLED";
})(POPUP_RESULT || (POPUP_RESULT = {}));
//# sourceMappingURL=popup.js.map

/***/ })

/******/ });
/************************************************************************/
/******/ // The module cache
/******/ var __webpack_module_cache__ = {};
/******/ 
/******/ // The require function
/******/ function __webpack_require__(moduleId) {
/******/ 	// Check if module is in cache
/******/ 	var cachedModule = __webpack_module_cache__[moduleId];
/******/ 	if (cachedModule !== undefined) {
/******/ 		return cachedModule.exports;
/******/ 	}
/******/ 	// Create a new module (and put it into the cache)
/******/ 	var module = __webpack_module_cache__[moduleId] = {
/******/ 		// no module.id needed
/******/ 		// no module.loaded needed
/******/ 		exports: {}
/******/ 	};
/******/ 
/******/ 	// Execute the module function
/******/ 	__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 
/******/ 	// Return the exports of the module
/******/ 	return module.exports;
/******/ }
/******/ 
/************************************************************************/
/******/ /* webpack/runtime/define property getters */
/******/ (() => {
/******/ 	// define getter functions for harmony exports
/******/ 	__webpack_require__.d = (exports, definition) => {
/******/ 		for(var key in definition) {
/******/ 			if(__webpack_require__.o(definition, key) && !__webpack_require__.o(exports, key)) {
/******/ 				Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
/******/ 			}
/******/ 		}
/******/ 	};
/******/ })();
/******/ 
/******/ /* webpack/runtime/hasOwnProperty shorthand */
/******/ (() => {
/******/ 	__webpack_require__.o = (obj, prop) => (Object.prototype.hasOwnProperty.call(obj, prop))
/******/ })();
/******/ 
/******/ /* webpack/runtime/make namespace object */
/******/ (() => {
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = (exports) => {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/ })();
/******/ 
/************************************************************************/
var __webpack_exports__ = {};
// This entry needs to be wrapped in an IIFE because it uses a non-standard name for the exports (exports).
(() => {
var exports = __webpack_exports__;


function _createForOfIteratorHelper(r, e) { var t = "undefined" != typeof Symbol && r[Symbol.iterator] || r["@@iterator"]; if (!t) { if (Array.isArray(r) || (t = _unsupportedIterableToArray(r)) || e && r && "number" == typeof r.length) { t && (r = t); var _n = 0, F = function F() {}; return { s: F, n: function n() { return _n >= r.length ? { done: !0 } : { done: !1, value: r[_n++] }; }, e: function e(r) { throw r; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var o, a = !0, u = !1; return { s: function s() { t = t.call(r); }, n: function n() { var r = t.next(); return a = r.done, r; }, e: function e(r) { u = !0, o = r; }, f: function f() { try { a || null == t["return"] || t["return"](); } finally { if (u) throw o; } } }; }
function _unsupportedIterableToArray(r, a) { if (r) { if ("string" == typeof r) return _arrayLikeToArray(r, a); var t = {}.toString.call(r).slice(8, -1); return "Object" === t && r.constructor && (t = r.constructor.name), "Map" === t || "Set" === t ? Array.from(r) : "Arguments" === t || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(t) ? _arrayLikeToArray(r, a) : void 0; } }
function _arrayLikeToArray(r, a) { (null == a || a > r.length) && (a = r.length); for (var e = 0, n = Array(a); e < a; e++) n[e] = r[e]; return n; }
function ownKeys(e, r) { var t = Object.keys(e); if (Object.getOwnPropertySymbols) { var o = Object.getOwnPropertySymbols(e); r && (o = o.filter(function (r) { return Object.getOwnPropertyDescriptor(e, r).enumerable; })), t.push.apply(t, o); } return t; }
function _objectSpread(e) { for (var r = 1; r < arguments.length; r++) { var t = null != arguments[r] ? arguments[r] : {}; r % 2 ? ownKeys(Object(t), !0).forEach(function (r) { _defineProperty(e, r, t[r]); }) : Object.getOwnPropertyDescriptors ? Object.defineProperties(e, Object.getOwnPropertyDescriptors(t)) : ownKeys(Object(t)).forEach(function (r) { Object.defineProperty(e, r, Object.getOwnPropertyDescriptor(t, r)); }); } return e; }
function _defineProperty(e, r, t) { return (r = _toPropertyKey(r)) in e ? Object.defineProperty(e, r, { value: t, enumerable: !0, configurable: !0, writable: !0 }) : e[r] = t, e; }
function _toPropertyKey(t) { var i = _toPrimitive(t, "string"); return "symbol" == _typeof(i) ? i : i + ""; }
function _toPrimitive(t, r) { if ("object" != _typeof(t) || !t) return t; var e = t[Symbol.toPrimitive]; if (void 0 !== e) { var i = e.call(t, r || "default"); if ("object" != _typeof(i)) return i; throw new TypeError("@@toPrimitive must return a primitive value."); } return ("string" === r ? String : Number)(t); }
function _regeneratorRuntime() { "use strict"; /*! regenerator-runtime -- Copyright (c) 2014-present, Facebook, Inc. -- license (MIT): https://github.com/facebook/regenerator/blob/main/LICENSE */ _regeneratorRuntime = function _regeneratorRuntime() { return e; }; var t, e = {}, r = Object.prototype, n = r.hasOwnProperty, o = Object.defineProperty || function (t, e, r) { t[e] = r.value; }, i = "function" == typeof Symbol ? Symbol : {}, a = i.iterator || "@@iterator", c = i.asyncIterator || "@@asyncIterator", u = i.toStringTag || "@@toStringTag"; function define(t, e, r) { return Object.defineProperty(t, e, { value: r, enumerable: !0, configurable: !0, writable: !0 }), t[e]; } try { define({}, ""); } catch (t) { define = function define(t, e, r) { return t[e] = r; }; } function wrap(t, e, r, n) { var i = e && e.prototype instanceof Generator ? e : Generator, a = Object.create(i.prototype), c = new Context(n || []); return o(a, "_invoke", { value: makeInvokeMethod(t, r, c) }), a; } function tryCatch(t, e, r) { try { return { type: "normal", arg: t.call(e, r) }; } catch (t) { return { type: "throw", arg: t }; } } e.wrap = wrap; var h = "suspendedStart", l = "suspendedYield", f = "executing", s = "completed", y = {}; function Generator() {} function GeneratorFunction() {} function GeneratorFunctionPrototype() {} var p = {}; define(p, a, function () { return this; }); var d = Object.getPrototypeOf, v = d && d(d(values([]))); v && v !== r && n.call(v, a) && (p = v); var g = GeneratorFunctionPrototype.prototype = Generator.prototype = Object.create(p); function defineIteratorMethods(t) { ["next", "throw", "return"].forEach(function (e) { define(t, e, function (t) { return this._invoke(e, t); }); }); } function AsyncIterator(t, e) { function invoke(r, o, i, a) { var c = tryCatch(t[r], t, o); if ("throw" !== c.type) { var u = c.arg, h = u.value; return h && "object" == _typeof(h) && n.call(h, "__await") ? e.resolve(h.__await).then(function (t) { invoke("next", t, i, a); }, function (t) { invoke("throw", t, i, a); }) : e.resolve(h).then(function (t) { u.value = t, i(u); }, function (t) { return invoke("throw", t, i, a); }); } a(c.arg); } var r; o(this, "_invoke", { value: function value(t, n) { function callInvokeWithMethodAndArg() { return new e(function (e, r) { invoke(t, n, e, r); }); } return r = r ? r.then(callInvokeWithMethodAndArg, callInvokeWithMethodAndArg) : callInvokeWithMethodAndArg(); } }); } function makeInvokeMethod(e, r, n) { var o = h; return function (i, a) { if (o === f) throw Error("Generator is already running"); if (o === s) { if ("throw" === i) throw a; return { value: t, done: !0 }; } for (n.method = i, n.arg = a;;) { var c = n.delegate; if (c) { var u = maybeInvokeDelegate(c, n); if (u) { if (u === y) continue; return u; } } if ("next" === n.method) n.sent = n._sent = n.arg;else if ("throw" === n.method) { if (o === h) throw o = s, n.arg; n.dispatchException(n.arg); } else "return" === n.method && n.abrupt("return", n.arg); o = f; var p = tryCatch(e, r, n); if ("normal" === p.type) { if (o = n.done ? s : l, p.arg === y) continue; return { value: p.arg, done: n.done }; } "throw" === p.type && (o = s, n.method = "throw", n.arg = p.arg); } }; } function maybeInvokeDelegate(e, r) { var n = r.method, o = e.iterator[n]; if (o === t) return r.delegate = null, "throw" === n && e.iterator["return"] && (r.method = "return", r.arg = t, maybeInvokeDelegate(e, r), "throw" === r.method) || "return" !== n && (r.method = "throw", r.arg = new TypeError("The iterator does not provide a '" + n + "' method")), y; var i = tryCatch(o, e.iterator, r.arg); if ("throw" === i.type) return r.method = "throw", r.arg = i.arg, r.delegate = null, y; var a = i.arg; return a ? a.done ? (r[e.resultName] = a.value, r.next = e.nextLoc, "return" !== r.method && (r.method = "next", r.arg = t), r.delegate = null, y) : a : (r.method = "throw", r.arg = new TypeError("iterator result is not an object"), r.delegate = null, y); } function pushTryEntry(t) { var e = { tryLoc: t[0] }; 1 in t && (e.catchLoc = t[1]), 2 in t && (e.finallyLoc = t[2], e.afterLoc = t[3]), this.tryEntries.push(e); } function resetTryEntry(t) { var e = t.completion || {}; e.type = "normal", delete e.arg, t.completion = e; } function Context(t) { this.tryEntries = [{ tryLoc: "root" }], t.forEach(pushTryEntry, this), this.reset(!0); } function values(e) { if (e || "" === e) { var r = e[a]; if (r) return r.call(e); if ("function" == typeof e.next) return e; if (!isNaN(e.length)) { var o = -1, i = function next() { for (; ++o < e.length;) if (n.call(e, o)) return next.value = e[o], next.done = !1, next; return next.value = t, next.done = !0, next; }; return i.next = i; } } throw new TypeError(_typeof(e) + " is not iterable"); } return GeneratorFunction.prototype = GeneratorFunctionPrototype, o(g, "constructor", { value: GeneratorFunctionPrototype, configurable: !0 }), o(GeneratorFunctionPrototype, "constructor", { value: GeneratorFunction, configurable: !0 }), GeneratorFunction.displayName = define(GeneratorFunctionPrototype, u, "GeneratorFunction"), e.isGeneratorFunction = function (t) { var e = "function" == typeof t && t.constructor; return !!e && (e === GeneratorFunction || "GeneratorFunction" === (e.displayName || e.name)); }, e.mark = function (t) { return Object.setPrototypeOf ? Object.setPrototypeOf(t, GeneratorFunctionPrototype) : (t.__proto__ = GeneratorFunctionPrototype, define(t, u, "GeneratorFunction")), t.prototype = Object.create(g), t; }, e.awrap = function (t) { return { __await: t }; }, defineIteratorMethods(AsyncIterator.prototype), define(AsyncIterator.prototype, c, function () { return this; }), e.AsyncIterator = AsyncIterator, e.async = function (t, r, n, o, i) { void 0 === i && (i = Promise); var a = new AsyncIterator(wrap(t, r, n, o), i); return e.isGeneratorFunction(r) ? a : a.next().then(function (t) { return t.done ? t.value : a.next(); }); }, defineIteratorMethods(g), define(g, u, "Generator"), define(g, a, function () { return this; }), define(g, "toString", function () { return "[object Generator]"; }), e.keys = function (t) { var e = Object(t), r = []; for (var n in e) r.push(n); return r.reverse(), function next() { for (; r.length;) { var t = r.pop(); if (t in e) return next.value = t, next.done = !1, next; } return next.done = !0, next; }; }, e.values = values, Context.prototype = { constructor: Context, reset: function reset(e) { if (this.prev = 0, this.next = 0, this.sent = this._sent = t, this.done = !1, this.delegate = null, this.method = "next", this.arg = t, this.tryEntries.forEach(resetTryEntry), !e) for (var r in this) "t" === r.charAt(0) && n.call(this, r) && !isNaN(+r.slice(1)) && (this[r] = t); }, stop: function stop() { this.done = !0; var t = this.tryEntries[0].completion; if ("throw" === t.type) throw t.arg; return this.rval; }, dispatchException: function dispatchException(e) { if (this.done) throw e; var r = this; function handle(n, o) { return a.type = "throw", a.arg = e, r.next = n, o && (r.method = "next", r.arg = t), !!o; } for (var o = this.tryEntries.length - 1; o >= 0; --o) { var i = this.tryEntries[o], a = i.completion; if ("root" === i.tryLoc) return handle("end"); if (i.tryLoc <= this.prev) { var c = n.call(i, "catchLoc"), u = n.call(i, "finallyLoc"); if (c && u) { if (this.prev < i.catchLoc) return handle(i.catchLoc, !0); if (this.prev < i.finallyLoc) return handle(i.finallyLoc); } else if (c) { if (this.prev < i.catchLoc) return handle(i.catchLoc, !0); } else { if (!u) throw Error("try statement without catch or finally"); if (this.prev < i.finallyLoc) return handle(i.finallyLoc); } } } }, abrupt: function abrupt(t, e) { for (var r = this.tryEntries.length - 1; r >= 0; --r) { var o = this.tryEntries[r]; if (o.tryLoc <= this.prev && n.call(o, "finallyLoc") && this.prev < o.finallyLoc) { var i = o; break; } } i && ("break" === t || "continue" === t) && i.tryLoc <= e && e <= i.finallyLoc && (i = null); var a = i ? i.completion : {}; return a.type = t, a.arg = e, i ? (this.method = "next", this.next = i.finallyLoc, y) : this.complete(a); }, complete: function complete(t, e) { if ("throw" === t.type) throw t.arg; return "break" === t.type || "continue" === t.type ? this.next = t.arg : "return" === t.type ? (this.rval = this.arg = t.arg, this.method = "return", this.next = "end") : "normal" === t.type && e && (this.next = e), y; }, finish: function finish(t) { for (var e = this.tryEntries.length - 1; e >= 0; --e) { var r = this.tryEntries[e]; if (r.finallyLoc === t) return this.complete(r.completion, r.afterLoc), resetTryEntry(r), y; } }, "catch": function _catch(t) { for (var e = this.tryEntries.length - 1; e >= 0; --e) { var r = this.tryEntries[e]; if (r.tryLoc === t) { var n = r.completion; if ("throw" === n.type) { var o = n.arg; resetTryEntry(r); } return o; } } throw Error("illegal catch attempt"); }, delegateYield: function delegateYield(e, r, n) { return this.delegate = { iterator: values(e), resultName: r, nextLoc: n }, "next" === this.method && (this.arg = t), y; } }, e; }
function asyncGeneratorStep(n, t, e, r, o, a, c) { try { var i = n[a](c), u = i.value; } catch (n) { return void e(n); } i.done ? t(u) : Promise.resolve(u).then(r, o); }
function _asyncToGenerator(n) { return function () { var t = this, e = arguments; return new Promise(function (r, o) { var a = n.apply(t, e); function _next(n) { asyncGeneratorStep(a, r, o, _next, _throw, "next", n); } function _throw(n) { asyncGeneratorStep(a, r, o, _next, _throw, "throw", n); } _next(void 0); }); }; }
function _typeof(o) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (o) { return typeof o; } : function (o) { return o && "function" == typeof Symbol && o.constructor === Symbol && o !== Symbol.prototype ? "symbol" : typeof o; }, _typeof(o); }
Object.defineProperty(exports, "B", ({
  value: true
}));
var types_1 = __webpack_require__(886);
var popup_1 = __webpack_require__(452);
var config_1 = __webpack_require__(389);
var mcp_client_js_1 = __webpack_require__(182);
var extensionName = 'SillyTavern-MCP-Client';
var globalContext = SillyTavern.getContext();
var EXTENSION_SETTINGS_KEY = 'mcp';
function getExtensionSettings() {
  var context = SillyTavern.getContext();
  return context.extensionSettings[EXTENSION_SETTINGS_KEY];
}
var DEFAULT_SETTINGS = {
  enabled: false
};
function initializeDefaultSettings() {
  var _globalContext$extens;
  globalContext.extensionSettings[EXTENSION_SETTINGS_KEY] = ((_globalContext$extens = globalContext.extensionSettings) === null || _globalContext$extens === void 0 ? void 0 : _globalContext$extens[EXTENSION_SETTINGS_KEY]) || {};
  function initializeRecursively(target, defaults) {
    var anyChange = false;
    for (var _i = 0, _Object$keys = Object.keys(defaults); _i < _Object$keys.length; _i++) {
      var key = _Object$keys[_i];
      if (target[key] === undefined) {
        target[key] = defaults[key];
        anyChange = true;
      } else if (_typeof(defaults[key]) === 'object' && defaults[key] !== null) {
        target[key] = target[key] || {};
        if (initializeRecursively(target[key], defaults[key])) {
          anyChange = true;
        }
      }
    }
    return anyChange;
  }
  if (initializeRecursively(globalContext.extensionSettings[EXTENSION_SETTINGS_KEY], DEFAULT_SETTINGS)) {
    globalContext.saveSettingsDebounced();
  }
}
function handleUIChanges() {
  return _handleUIChanges.apply(this, arguments);
}
function _handleUIChanges() {
  _handleUIChanges = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee12() {
    var settingsHtml, settings, createAndShowPopup, _createAndShowPopup, populateToolsList, _populateToolsList;
    return _regeneratorRuntime().wrap(function _callee12$(_context13) {
      while (1) switch (_context13.prev = _context13.next) {
        case 0:
          _populateToolsList = function _populateToolsList3() {
            _populateToolsList = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee11(popupContent) {
              var toolsList, serverTemplate, allServers, noServers, _iterator, _step, _loop;
              return _regeneratorRuntime().wrap(function _callee11$(_context12) {
                while (1) switch (_context12.prev = _context12.next) {
                  case 0:
                    toolsList = popupContent.querySelector('#mcp-tools-list');
                    serverTemplate = popupContent.querySelector('#server-section-template'); // Clear and populate tools list
                    toolsList.innerHTML = '';
                    _context12.next = 5;
                    return mcp_client_js_1.MCPClient.getServers();
                  case 5:
                    allServers = _context12.sent;
                    if (!(allServers.length === 0)) {
                      _context12.next = 13;
                      break;
                    }
                    noServers = document.createElement('div');
                    noServers.className = 'no-servers';
                    noServers.textContent = 'No MCP servers found.';
                    toolsList.appendChild(noServers);
                    _context12.next = 29;
                    break;
                  case 13:
                    _iterator = _createForOfIteratorHelper(allServers);
                    _context12.prev = 14;
                    _loop = /*#__PURE__*/_regeneratorRuntime().mark(function _loop() {
                      var server, isConnected, serverNode, serverSection, serverToggle, serverHeader, deleteButton, tools, _toolsList;
                      return _regeneratorRuntime().wrap(function _loop$(_context11) {
                        while (1) switch (_context11.prev = _context11.next) {
                          case 0:
                            server = _step.value;
                            isConnected = mcp_client_js_1.MCPClient.isConnected(server.name); // Clone server template
                            serverNode = serverTemplate.content.cloneNode(true);
                            serverSection = serverNode.querySelector('.server-tools-section');
                            if (!isConnected) serverSection.classList.add('disabled');
                            // Set server name and enabled state
                            serverSection.querySelector('h4').textContent = server.name;
                            serverToggle = serverSection.querySelector('.server-toggle');
                            serverToggle.checked = isConnected;
                            serverToggle.dataset.server = server.name;
                            // Add accordion click handler
                            serverHeader = serverSection.querySelector('.server-header');
                            serverHeader.addEventListener('click', function (e) {
                              // Don't trigger accordion when clicking the toggle
                              if (e.target.closest('.checkbox_label')) return;
                              var toolsList = serverSection.querySelector('.tools-list');
                              var chevron = serverHeader.querySelector('i');
                              toolsList.classList.toggle('collapsed');
                              chevron.style.transform = toolsList.classList.contains('collapsed') ? 'rotate(-90deg)' : '';
                            });
                            // Add server toggle handler
                            serverToggle.addEventListener('change', /*#__PURE__*/_asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee9() {
                              var serverSection, label, labelSpan, originalSpanText, enabled, disabledServers;
                              return _regeneratorRuntime().wrap(function _callee9$(_context9) {
                                while (1) switch (_context9.prev = _context9.next) {
                                  case 0:
                                    serverSection = serverToggle.closest('.server-tools-section');
                                    label = serverToggle.closest('.checkbox_label'); // Show loading state
                                    labelSpan = label.querySelector('span');
                                    originalSpanText = labelSpan.textContent;
                                    serverToggle.disabled = true;
                                    labelSpan.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Updating...';
                                    enabled = serverToggle.checked;
                                    _context9.prev = 7;
                                    serverSection.classList.toggle('disabled', !enabled);
                                    // Get all servers and update disabled list
                                    disabledServers = Array.from(popupContent.querySelectorAll('.server-toggle')).filter(function (toggle) {
                                      return !toggle.checked;
                                    }).map(function (toggle) {
                                      return toggle.dataset.server;
                                    });
                                    _context9.next = 12;
                                    return mcp_client_js_1.MCPClient.updateDisabledServers(disabledServers);
                                  case 12:
                                    // Show success state briefly
                                    labelSpan.innerHTML = '<i class="fa-solid fa-check"></i> Updated';
                                    _context9.next = 23;
                                    break;
                                  case 15:
                                    _context9.prev = 15;
                                    _context9.t0 = _context9["catch"](7);
                                    console.error('Error updating server state:', _context9.t0);
                                    // Show error state and revert toggle
                                    labelSpan.innerHTML = '<i class="fa-solid fa-exclamation-triangle"></i> Failed';
                                    serverToggle.checked = !serverToggle.checked;
                                    serverSection.classList.toggle('disabled', !serverToggle.checked);
                                    _context9.next = 23;
                                    return (0, config_1.st_echo)('error', "Failed to ".concat(enabled ? 'enable' : 'disable', " server \"").concat(server.name, "\""));
                                  case 23:
                                    // Reset label after delay
                                    setTimeout(function () {
                                      labelSpan.textContent = originalSpanText;
                                      serverToggle.disabled = false;
                                    }, 1500);
                                  case 24:
                                  case "end":
                                    return _context9.stop();
                                }
                              }, _callee9, null, [[7, 15]]);
                            })));
                            // Add delete server handler
                            deleteButton = serverSection.querySelector('.delete-server');
                            deleteButton.addEventListener('click', /*#__PURE__*/function () {
                              var _ref9 = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee10(e) {
                                var name, confirm;
                                return _regeneratorRuntime().wrap(function _callee10$(_context10) {
                                  while (1) switch (_context10.prev = _context10.next) {
                                    case 0:
                                      e.stopPropagation(); // Prevent accordion from triggering
                                      name = server.name;
                                      _context10.next = 4;
                                      return globalContext.Popup.show.confirm("Are you sure you want to delete the selected server?", name);
                                    case 4:
                                      confirm = _context10.sent;
                                      if (!confirm) {
                                        _context10.next = 19;
                                        break;
                                      }
                                      _context10.prev = 6;
                                      _context10.next = 9;
                                      return mcp_client_js_1.MCPClient.deleteServer(name);
                                    case 9:
                                      console.log("Server \"".concat(name, "\" removed successfully"));
                                      _context10.next = 12;
                                      return populateToolsList(popupContent);
                                    case 12:
                                      _context10.next = 19;
                                      break;
                                    case 14:
                                      _context10.prev = 14;
                                      _context10.t0 = _context10["catch"](6);
                                      console.error('Error removing server:', _context10.t0);
                                      _context10.next = 19;
                                      return (0, config_1.st_echo)('error', "Error removing server \"".concat(name, "\""));
                                    case 19:
                                    case "end":
                                      return _context10.stop();
                                  }
                                }, _callee10, null, [[6, 14]]);
                              }));
                              return function (_x7) {
                                return _ref9.apply(this, arguments);
                              };
                            }());
                            // Add tools if available
                            _context11.next = 16;
                            return mcp_client_js_1.MCPClient.getServerTools(server.name);
                          case 16:
                            tools = _context11.sent;
                            if (tools && tools.length > 0) {
                              _toolsList = serverSection.querySelector('.tools-list');
                              tools.forEach(function (tool) {
                                var toolItem = document.createElement('div');
                                toolItem.className = 'tool-item';
                                toolItem.innerHTML = "\n              <div class=\"tool-header\">\n                <span class=\"tool-name\">".concat(tool.name, "</span>\n                <label class=\"checkbox_label\">\n                  <input type=\"checkbox\" class=\"tool-toggle\" ").concat(tool._enabled ? 'checked' : '', " />\n                  <span>Enable</span>\n                </label>\n              </div>\n              <div class=\"tool-description\">").concat(tool.description || 'No description available', "</div>\n            ");
                                var toolToggle = toolItem.querySelector('.tool-toggle');
                                toolToggle.dataset.server = server.name;
                                toolToggle.dataset.tool = tool.name;
                                _toolsList.appendChild(toolItem);
                              });
                            }
                            toolsList.appendChild(serverSection);
                          case 19:
                          case "end":
                            return _context11.stop();
                        }
                      }, _loop);
                    });
                    _iterator.s();
                  case 17:
                    if ((_step = _iterator.n()).done) {
                      _context12.next = 21;
                      break;
                    }
                    return _context12.delegateYield(_loop(), "t0", 19);
                  case 19:
                    _context12.next = 17;
                    break;
                  case 21:
                    _context12.next = 26;
                    break;
                  case 23:
                    _context12.prev = 23;
                    _context12.t1 = _context12["catch"](14);
                    _iterator.e(_context12.t1);
                  case 26:
                    _context12.prev = 26;
                    _iterator.f();
                    return _context12.finish(26);
                  case 29:
                  case "end":
                    return _context12.stop();
                }
              }, _callee11, null, [[14, 23, 26, 29]]);
            }));
            return _populateToolsList.apply(this, arguments);
          };
          populateToolsList = function _populateToolsList2(_x3) {
            return _populateToolsList.apply(this, arguments);
          };
          _createAndShowPopup = function _createAndShowPopup3() {
            _createAndShowPopup = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee8(templatePath) {
              var content, tempDiv, popupContent;
              return _regeneratorRuntime().wrap(function _callee8$(_context8) {
                while (1) switch (_context8.prev = _context8.next) {
                  case 0:
                    _context8.next = 2;
                    return globalContext.renderExtensionTemplateAsync("third-party/".concat(extensionName), templatePath);
                  case 2:
                    content = _context8.sent;
                    // Create popup content
                    tempDiv = document.createElement('div');
                    tempDiv.innerHTML = content;
                    popupContent = tempDiv.firstElementChild; // Show popup first so template is in the DOM
                    globalContext.callGenericPopup($(popupContent), popup_1.POPUP_TYPE.DISPLAY);
                    return _context8.abrupt("return", popupContent);
                  case 8:
                  case "end":
                    return _context8.stop();
                }
              }, _callee8);
            }));
            return _createAndShowPopup.apply(this, arguments);
          };
          createAndShowPopup = function _createAndShowPopup2(_x2) {
            return _createAndShowPopup.apply(this, arguments);
          };
          _context13.next = 6;
          return globalContext.renderExtensionTemplateAsync("third-party/".concat(extensionName), 'templates/settings');
        case 6:
          settingsHtml = _context13.sent;
          $('#extensions_settings').append(settingsHtml);
          settings = getExtensionSettings();
          $('#mcp_enabled').prop('checked', settings.enabled).on('change', /*#__PURE__*/_asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee2() {
            var toggle, label, labelSpan, originalSpanText, enabled;
            return _regeneratorRuntime().wrap(function _callee2$(_context2) {
              while (1) switch (_context2.prev = _context2.next) {
                case 0:
                  toggle = $(this);
                  label = toggle.parent('.checkbox_label');
                  labelSpan = label.find('span');
                  originalSpanText = labelSpan.text(); // Show loading state
                  toggle.prop('disabled', true);
                  labelSpan.html('<i class="fa-solid fa-spinner fa-spin"></i> Updating...');
                  enabled = toggle.prop('checked');
                  settings.enabled = enabled;
                  globalContext.saveSettingsDebounced();
                  // Use MCPClient's handleTools method to manage tool registration
                  _context2.prev = 9;
                  _context2.next = 12;
                  return mcp_client_js_1.MCPClient.handleTools(enabled);
                case 12:
                  // Show success state briefly
                  labelSpan.html('<i class="fa-solid fa-check"></i> Updated');
                  _context2.next = 20;
                  break;
                case 15:
                  _context2.prev = 15;
                  _context2.t0 = _context2["catch"](9);
                  console.error("[MCPClient] Error handling MCP tools:", _context2.t0);
                  // Show error state and revert toggle
                  labelSpan.html('<i class="fa-solid fa-exclamation-triangle"></i> Failed');
                  (0, config_1.st_echo)('error', "[MCPClient] Error handling MCP tools: ".concat(_context2.t0));
                case 20:
                  // Reset label after delay
                  setTimeout(function () {
                    labelSpan.text(originalSpanText);
                    toggle.prop('disabled', false);
                  }, 1500);
                case 21:
                case "end":
                  return _context2.stop();
              }
            }, _callee2, this, [[9, 15]]);
          })));
          /**
           * Creates and shows a popup from a template
           * @param templatePath The path to the template (without the extension)
           * @returns The popup content element
           */

          /**
           * Populates the tools list in the popup
           * @param popupContent The popup content element
           */

          $('#mcp_manage_tools').on('click', /*#__PURE__*/_asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee7() {
            var _popupContent$querySe, _popupContent$querySe2, _popupContent$querySe3, _popupContent$querySe4;
            var popupContent, addButton, submitButton, serverInput;
            return _regeneratorRuntime().wrap(function _callee7$(_context7) {
              while (1) switch (_context7.prev = _context7.next) {
                case 0:
                  _context7.next = 2;
                  return createAndShowPopup('templates/tools');
                case 2:
                  popupContent = _context7.sent;
                  _context7.next = 5;
                  return populateToolsList(popupContent);
                case 5:
                  // Add server form handlers
                  addButton = popupContent.querySelector('#add-server');
                  submitButton = popupContent.querySelector('#submit-server');
                  serverInput = $('#server-input'); // Enable add button initially
                  addButton.disabled = false;
                  // Enable submit button only when there's input
                  serverInput.on('input', function () {
                    submitButton.disabled = !serverInput.val();
                  });
                  addButton.addEventListener('click', function () {
                    $('#add-server-form').show();
                    addButton.disabled = true;
                  });
                  (_popupContent$querySe = popupContent.querySelector('#cancel-server')) === null || _popupContent$querySe === void 0 || _popupContent$querySe.addEventListener('click', function () {
                    $('#add-server-form').hide();
                    serverInput.val('');
                    addButton.disabled = false;
                    submitButton.disabled = true;
                  });
                  (_popupContent$querySe2 = popupContent.querySelector('#submit-server')) === null || _popupContent$querySe2 === void 0 || _popupContent$querySe2.addEventListener('click', /*#__PURE__*/_asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee3() {
                    var submitButton, input, originalText, serverName, config, jsonConfig, serverEntry, serverConfig, parts, packageName;
                    return _regeneratorRuntime().wrap(function _callee3$(_context3) {
                      while (1) switch (_context3.prev = _context3.next) {
                        case 0:
                          submitButton = popupContent.querySelector('#submit-server');
                          input = $('#server-input').val();
                          if (input) {
                            _context3.next = 4;
                            break;
                          }
                          return _context3.abrupt("return");
                        case 4:
                          // Show loading state
                          originalText = submitButton.innerHTML;
                          submitButton.disabled = true;
                          submitButton.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Adding...';
                          serverName = '';
                          _context3.prev = 8;
                          if (!input.trim().startsWith('{')) {
                            _context3.next = 21;
                            break;
                          }
                          jsonConfig = JSON.parse(input);
                          if (jsonConfig.mcpServers) {
                            _context3.next = 13;
                            break;
                          }
                          throw new Error('Invalid config: missing mcpServers object');
                        case 13:
                          serverEntry = Object.entries(jsonConfig.mcpServers)[0];
                          if (serverEntry) {
                            _context3.next = 16;
                            break;
                          }
                          throw new Error('Invalid config: no server configuration found');
                        case 16:
                          serverName = serverEntry[0];
                          serverConfig = serverEntry[1];
                          config = _objectSpread({
                            type: 'stdio'
                          }, serverConfig);
                          _context3.next = 25;
                          break;
                        case 21:
                          // Assume it's an command
                          parts = input.trim().split(' '); // Get the last part of the package name for server name
                          packageName = parts[parts.length - 1];
                          serverName = packageName.split('/').pop();
                          config = {
                            command: parts[0],
                            args: parts.slice(1),
                            env: {},
                            type: 'stdio'
                          };
                        case 25:
                          _context3.next = 27;
                          return mcp_client_js_1.MCPClient.addServer(serverName, config);
                        case 27:
                          console.log("Server \"".concat(serverName, "\" added successfully"));
                          // If we get here, either server was added successfully with no connection
                          // attempt, or it was added and connected successfully
                          _context3.next = 30;
                          return (0, config_1.st_echo)('success', "Server \"".concat(serverName, "\" added successfully"));
                        case 30:
                          // Show success state briefly
                          submitButton.innerHTML = '<i class="fa-solid fa-check"></i> Success';
                          submitButton.style.background = 'var(--active)';
                          // Hide form and reset input
                          $('#add-server-form').hide();
                          $('#server-input').val('');
                          _context3.next = 36;
                          return populateToolsList(popupContent);
                        case 36:
                          _context3.next = 56;
                          break;
                        case 38:
                          _context3.prev = 38;
                          _context3.t0 = _context3["catch"](8);
                          console.error('Error adding server:', _context3.t0);
                          if (!_context3.t0.isConnectError) {
                            _context3.next = 52;
                            break;
                          }
                          _context3.next = 44;
                          return (0, config_1.st_echo)('warning', _context3.t0.message);
                        case 44:
                          // Show warning state
                          submitButton.innerHTML = '<i class="fa-solid fa-exclamation-triangle"></i> Added With Warning';
                          submitButton.style.background = 'var(--warning)';
                          // Still hide form and update UI since server was added
                          $('#add-server-form').hide();
                          $('#server-input').val('');
                          _context3.next = 50;
                          return populateToolsList(popupContent);
                        case 50:
                          _context3.next = 56;
                          break;
                        case 52:
                          _context3.next = 54;
                          return (0, config_1.st_echo)('error', "Error adding server: ".concat(_context3.t0.message));
                        case 54:
                          // Show error state
                          submitButton.innerHTML = '<i class="fa-solid fa-exclamation-triangle"></i> Error';
                          submitButton.style.background = 'var(--error)';
                        case 56:
                          // Reset button after delay
                          setTimeout(function () {
                            submitButton.innerHTML = originalText;
                            submitButton.style.background = '';
                            // Enable button if there's input
                            submitButton.disabled = !serverInput.val();
                            addButton.disabled = false;
                          }, 1500);
                        case 57:
                        case "end":
                          return _context3.stop();
                      }
                    }, _callee3, null, [[8, 38]]);
                  })));
                  // Add reload all tools button handler
                  (_popupContent$querySe3 = popupContent.querySelector('#reload-all-tools')) === null || _popupContent$querySe3 === void 0 || _popupContent$querySe3.addEventListener('click', /*#__PURE__*/function () {
                    var _ref5 = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee4(e) {
                      var button, originalText;
                      return _regeneratorRuntime().wrap(function _callee4$(_context4) {
                        while (1) switch (_context4.prev = _context4.next) {
                          case 0:
                            button = e.currentTarget;
                            originalText = button.innerHTML; // Show loading state
                            button.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Refreshing';
                            button.disabled = true;
                            _context4.prev = 4;
                            _context4.next = 7;
                            return mcp_client_js_1.MCPClient.reloadAllTools();
                          case 7:
                            // Show success state
                            button.innerHTML = '<i class="fa-solid fa-check"></i> Success';
                            button.style.background = 'var(--active)';
                            console.log('Successfully reloaded all tools');
                            _context4.next = 12;
                            return (0, config_1.st_echo)('success', 'Successfully reloaded all tools');
                          case 12:
                            _context4.next = 14;
                            return populateToolsList(popupContent);
                          case 14:
                            // Reset button after delay
                            setTimeout(function () {
                              button.innerHTML = originalText;
                              button.style.background = '';
                              button.disabled = false;
                            }, 1500);
                            _context4.next = 25;
                            break;
                          case 17:
                            _context4.prev = 17;
                            _context4.t0 = _context4["catch"](4);
                            console.error('Error reloading tools:', _context4.t0);
                            button.innerHTML = '<i class="fa-solid fa-exclamation-triangle"></i> Error';
                            button.style.background = 'var(--warning)';
                            _context4.next = 24;
                            return (0, config_1.st_echo)('error', 'Error reloading tools');
                          case 24:
                            // Reset button after delay
                            setTimeout(function () {
                              button.innerHTML = originalText;
                              button.style.background = '';
                              button.disabled = false;
                            }, 1500);
                          case 25:
                          case "end":
                            return _context4.stop();
                        }
                      }, _callee4, null, [[4, 17]]);
                    }));
                    return function (_x4) {
                      return _ref5.apply(this, arguments);
                    };
                  }());
                  // Add settings button handler
                  (_popupContent$querySe4 = popupContent.querySelector('#open-server-settings')) === null || _popupContent$querySe4 === void 0 || _popupContent$querySe4.addEventListener('click', /*#__PURE__*/function () {
                    var _ref6 = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee5(e) {
                      var button, originalText;
                      return _regeneratorRuntime().wrap(function _callee5$(_context5) {
                        while (1) switch (_context5.prev = _context5.next) {
                          case 0:
                            button = e.currentTarget;
                            originalText = button.innerHTML; // Show loading state
                            button.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Opening';
                            button.disabled = true;
                            _context5.prev = 4;
                            _context5.next = 7;
                            return mcp_client_js_1.MCPClient.openServerSettings();
                          case 7:
                            // Show success state
                            button.innerHTML = '<i class="fa-solid fa-check"></i> Success';
                            button.style.background = 'var(--active)';
                            _context5.next = 18;
                            break;
                          case 11:
                            _context5.prev = 11;
                            _context5.t0 = _context5["catch"](4);
                            console.error('Error opening settings:', _context5.t0);
                            button.innerHTML = '<i class="fa-solid fa-exclamation-triangle"></i> Error';
                            button.style.background = 'var(--warning)';
                            _context5.next = 18;
                            return (0, config_1.st_echo)('error', 'Error opening settings');
                          case 18:
                            // Reset button after delay
                            setTimeout(function () {
                              button.innerHTML = originalText;
                              button.style.background = '';
                              button.disabled = false;
                            }, 1500);
                          case 19:
                          case "end":
                            return _context5.stop();
                        }
                      }, _callee5, null, [[4, 11]]);
                    }));
                    return function (_x5) {
                      return _ref6.apply(this, arguments);
                    };
                  }());
                  // Add toggle handler for tools after content is populated
                  popupContent.addEventListener('change', /*#__PURE__*/function () {
                    var _ref7 = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee6(e) {
                      var target, label, labelSpan, originalSpanText, serverName, tools, disabledTools;
                      return _regeneratorRuntime().wrap(function _callee6$(_context6) {
                        while (1) switch (_context6.prev = _context6.next) {
                          case 0:
                            target = e.target;
                            if (target.classList.contains('tool-toggle')) {
                              _context6.next = 3;
                              break;
                            }
                            return _context6.abrupt("return");
                          case 3:
                            label = target.closest('.checkbox_label');
                            labelSpan = label.querySelector('span');
                            originalSpanText = labelSpan.textContent; // Show loading state
                            target.disabled = true;
                            labelSpan.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Updating...';
                            _context6.prev = 8;
                            serverName = target.dataset.server;
                            _context6.next = 12;
                            return mcp_client_js_1.MCPClient.getServerTools(serverName);
                          case 12:
                            tools = _context6.sent;
                            if (tools) {
                              _context6.next = 15;
                              break;
                            }
                            throw new Error('Could not get server tools');
                          case 15:
                            // Collect all disabled tools for this server
                            disabledTools = tools.filter(function (tool) {
                              var checkbox = popupContent.querySelector("input.tool-toggle[data-server=\"".concat(serverName, "\"][data-tool=\"").concat(tool.name, "\"]"));
                              return !checkbox.checked;
                            }).map(function (tool) {
                              return tool.name;
                            });
                            _context6.next = 18;
                            return mcp_client_js_1.MCPClient.updateDisabledTools(serverName, disabledTools);
                          case 18:
                            // Show success state briefly
                            labelSpan.innerHTML = '<i class="fa-solid fa-check"></i> Updated';
                            _context6.next = 28;
                            break;
                          case 21:
                            _context6.prev = 21;
                            _context6.t0 = _context6["catch"](8);
                            console.error('Error updating tool state:', _context6.t0);
                            // Show error state and revert toggle
                            labelSpan.innerHTML = '<i class="fa-solid fa-exclamation-triangle"></i> Failed';
                            target.checked = !target.checked;
                            _context6.next = 28;
                            return (0, config_1.st_echo)('error', "Failed to update tool state");
                          case 28:
                            // Reset label after delay
                            setTimeout(function () {
                              labelSpan.textContent = originalSpanText;
                              target.disabled = false;
                            }, 1500);
                          case 29:
                          case "end":
                            return _context6.stop();
                        }
                      }, _callee6, null, [[8, 21]]);
                    }));
                    return function (_x6) {
                      return _ref7.apply(this, arguments);
                    };
                  }());
                case 16:
                case "end":
                  return _context7.stop();
              }
            }, _callee7);
          })));
          // Initial tool registration if enabled
          _context13.prev = 11;
          _context13.next = 14;
          return mcp_client_js_1.MCPClient.handleTools(settings.enabled);
        case 14:
          _context13.next = 20;
          break;
        case 16:
          _context13.prev = 16;
          _context13.t0 = _context13["catch"](11);
          _context13.next = 20;
          return (0, config_1.st_echo)('error', "Error handling tools: ".concat(_context13.t0.message));
        case 20:
        case "end":
          return _context13.stop();
      }
    }, _callee12, null, [[11, 16]]);
  }));
  return _handleUIChanges.apply(this, arguments);
}
function initializeEvents() {
  globalContext.eventSource.on(types_1.EventNames.CHAT_COMPLETION_SETTINGS_READY, /*#__PURE__*/function () {
    var _ref = _asyncToGenerator(/*#__PURE__*/_regeneratorRuntime().mark(function _callee(payload) {
      var _removeTitle, _removeProps;
      return _regeneratorRuntime().wrap(function _callee$(_context) {
        while (1) switch (_context.prev = _context.next) {
          case 0:
            if (payload.tools) {
              _context.next = 2;
              break;
            }
            return _context.abrupt("return");
          case 2:
            _removeTitle = function removeTitle(obj) {
              if (_typeof(obj) !== 'object' || obj === null) return;
              if (obj.title) {
                delete obj.title;
              }
              // Process properties if they exist
              if (obj.properties) {
                Object.values(obj.properties).forEach(function (prop) {
                  return _removeTitle(prop);
                });
              }
              // Process items for arrays
              if (obj.items) {
                _removeTitle(obj.items);
              }
              // Process allOf, anyOf, oneOf if they exist
              ['allOf', 'anyOf', 'oneOf'].forEach(function (key) {
                if (Array.isArray(obj[key])) {
                  obj[key].forEach(function (item) {
                    return _removeTitle(item);
                  });
                }
              });
            };
            payload.tools.forEach(function (tool) {
              _removeTitle(tool["function"].parameters);
            });
            _removeProps = function removeProps(obj) {
              if (_typeof(obj) !== 'object' || obj === null) return;
              delete obj.additionalProperties;
              delete obj["default"];
              // Process properties if they exist
              if (obj.properties) {
                if (obj.type === 'object' && Object.keys(obj.properties).length === 0) {
                  obj.properties = {
                    _dummy: {
                      type: 'string',
                      description: 'This is a placeholder property to satisfy MakerSuite requirements.'
                    }
                  };
                }
                Object.values(obj.properties).forEach(function (prop) {
                  return _removeProps(prop);
                });
              }
              // Process items for arrays
              if (obj.items) {
                _removeProps(obj.items);
              }
              // Process allOf, anyOf, oneOf if they exist
              ['allOf', 'anyOf', 'oneOf'].forEach(function (key) {
                if (Array.isArray(obj[key])) {
                  obj[key].forEach(function (item) {
                    return _removeProps(item);
                  });
                }
              });
            }; // makersuite is a special kid, we need to remove "additionalProperties" and "default" from all levels. Also doesn't accept empty params
            if (payload.chat_completion_source === 'makersuite') {
              payload.tools.forEach(function (tool) {
                _removeProps(tool["function"].parameters);
              });
            }
          case 6:
          case "end":
            return _context.stop();
        }
      }, _callee);
    }));
    return function (_x) {
      return _ref.apply(this, arguments);
    };
  }());
}
initializeDefaultSettings();
handleUIChanges();
initializeEvents();
})();

var __webpack_exports___esModule = __webpack_exports__.B;
export { __webpack_exports___esModule as __esModule };

//# sourceMappingURL=index.js.map