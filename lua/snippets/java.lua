local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

local snippets = {
  -- System.out.println like in VSCode/IntelliJ (sout)
  s({
    trig = "sout",
    name = "System.out.println",
    dscr = "Print to standard output",
  }, {
    t("System.out.println("),
    i(1),
    t(");"),
  }),
  
  -- System.err.println (serr)
  s({
    trig = "serr",
    name = "System.err.println",
    dscr = "Print to standard error",
  }, {
    t("System.err.println("),
    i(1),
    t(");"),
  }),
  
  -- Print with string format (souf)
  s({
    trig = "souf",
    name = "System.out.printf",
    dscr = "Print formatted string to standard output",
  }, {
    t("System.out.printf("),
    i(1, "\"Format string: %s\""),
    t(", "),
    i(2, "args"),
    t(");"),
  }),
  
  -- public static void main (psvm)
  s({
    trig = "psvm",
    name = "public static void main",
    dscr = "Public static void main method",
  }, {
    t("public static void main(String[] args) {"),
    t({"", "\t"}),
    i(0),
    t({"", "}"}),
  }),
  
  -- for loop (fori)
  s({
    trig = "fori",
    name = "for i loop",
    dscr = "Classic for i loop",
  }, {
    t("for (int "),
    i(1, "i"),
    t(" = "),
    i(2, "0"),
    t("; "),
    rep(1),
    t(" < "),
    i(3, "length"),
    t("; "),
    rep(1),
    t("++) {"),
    t({"", "\t"}),
    i(0),
    t({"", "}"})
  }),
  
  -- for each (fore)
  s({
    trig = "fore",
    name = "for each",
    dscr = "For each loop",
  }, {
    t("for ("),
    i(1, "Type"),
    t(" "),
    i(2, "item"),
    t(" : "),
    i(3, "collection"),
    t(") {"),
    t({"", "\t"}),
    i(0),
    t({"", "}"})
  }),
  
  -- try-catch block (try)
  s({
    trig = "try",
    name = "try/catch",
    dscr = "Try-catch block",
  }, {
    t({"try {", "\t"}),
    i(1),
    t({"", "} catch ("}),
    i(2, "Exception"),
    t(" "),
    i(3, "e"),
    t(") {"),
    t({"", "\t"}),
    i(0, "// Handle exception"),
    t({"", "}"})
  }),
  
  -- try with resources (tryr)
  s({
    trig = "tryr",
    name = "try with resources",
    dscr = "Try with resources",
  }, {
    t("try ("),
    i(1, "Resource resource = new Resource()"),
    t(") {"),
    t({"", "\t"}),
    i(0),
    t({"", "} catch (Exception e) {", "\te.printStackTrace();", "}"})
  }),
  
  -- if statement (if)
  s({
    trig = "if",
    name = "if statement",
    dscr = "If statement",
  }, {
    t("if ("),
    i(1, "condition"),
    t(") {"),
    t({"", "\t"}),
    i(0),
    t({"", "}"})
  }),
  
  -- if-else statement (ife)
  s({
    trig = "ife",
    name = "if-else statement",
    dscr = "If-else statement",
  }, {
    t("if ("),
    i(1, "condition"),
    t(") {"),
    t({"", "\t"}),
    i(2),
    t({"", "} else {", "\t"}),
    i(0),
    t({"", "}"})
  }),
  
  -- private field (prf)
  s({
    trig = "prf",
    name = "private field",
    dscr = "Private field",
  }, {
    t("private "),
    i(1, "Type"),
    t(" "),
    i(2, "name"),
    t(";"),
  }),
  
  -- public field (pubf)
  s({
    trig = "pubf",
    name = "public field",
    dscr = "Public field",
  }, {
    t("public "),
    i(1, "Type"),
    t(" "),
    i(2, "name"),
    t(";"),
  }),
  
  -- private method (prm)
  s({
    trig = "prm",
    name = "private method",
    dscr = "Private method",
  }, {
    t("private "),
    i(1, "void"),
    t(" "),
    i(2, "methodName"),
    t("("),
    i(3),
    t(") {"),
    t({"", "\t"}),
    i(0),
    t({"", "}"})
  }),
  
  -- public method (pubm)
  s({
    trig = "pubm",
    name = "public method",
    dscr = "Public method",
  }, {
    t("public "),
    i(1, "void"),
    t(" "),
    i(2, "methodName"),
    t("("),
    i(3),
    t(") {"),
    t({"", "\t"}),
    i(0),
    t({"", "}"})
  }),
  
  -- constructor (ctor)
  s({
    trig = "ctor",
    name = "constructor",
    dscr = "Constructor",
  }, {
    t("public "),
    f(function() return vim.fn.expand("%:t"):gsub("%.java$", "") end),
    t("("),
    i(1),
    t(") {"),
    t({"", "\t"}),
    i(0),
    t({"", "}"})
  }),
  
  -- toString override (tostr)
  s({
    trig = "tostr",
    name = "toString",
    dscr = "Override toString method",
  }, {
    t({"@Override", "public String toString() {", "\treturn "}),
    i(1, "\"" .. vim.fn.expand("%:t"):gsub("%.java$", "") .. "[\" + "),
    i(0, "field"),
    t(" + \"]\""),
    t({";", "}"})
  }),
  
  -- equals and hashCode (eqhash)
  s({
    trig = "eqhash",
    name = "equals and hashCode",
    dscr = "Override equals and hashCode methods",
  }, {
    t({"@Override", "public boolean equals(Object obj) {", "\tif (this == obj)", "\t\treturn true;", "\tif (obj == null || getClass() != obj.getClass())", "\t\treturn false;", "\t"}),
    f(function() return vim.fn.expand("%:t"):gsub("%.java$", "") end),
    t({" other = ("}),
    f(function() return vim.fn.expand("%:t"):gsub("%.java$", "") end),
    t({") obj;", "\treturn "}),
    i(1, "Objects.equals(field, other.field)"),
    t({";", "}", "", "@Override", "public int hashCode() {", "\treturn Objects.hash("}),
    i(0, "field"),
    t({");", "}"})
  }),
  
  -- new instance (new)
  s({
    trig = "new",
    name = "new instance",
    dscr = "Create new instance of a class",
  }, {
    i(1, "Type"),
    t(" "),
    i(2, "name"),
    t(" = new "),
    rep(1),
    t("("),
    i(3),
    t(");"),
  }),
  
  -- switch statement (switch)
  s({
    trig = "switch",
    name = "switch statement",
    dscr = "Switch statement",
  }, {
    t({"switch ("}),
    i(1, "expression"),
    t({") {", "\tcase "}),
    i(2, "value"),
    t({":", "\t\t"}),
    i(3),
    t({"", "\t\tbreak;", "\tdefault:", "\t\t"}),
    i(0),
    t({"", "}"})
  }),
  
  -- switch expression (Java 12+) (swe)
  s({
    trig = "swe",
    name = "switch expression",
    dscr = "Switch expression (Java 12+)",
  }, {
    i(1, "result"),
    t(" = switch ("),
    i(2, "expression"),
    t({") {", "\tcase "}),
    i(3, "value"),
    t({" -> "}),
    i(4, "returnValue"),
    t({";", "\tdefault -> "}),
    i(0, "defaultValue"),
    t({";", "}"})
  }),
  
  -- System.out.println print variable (soutv)
  s({
    trig = "soutv",
    name = "System.out.println with variable",
    dscr = "Print variable to standard output",
  }, {
    t("System.out.println(\""),
    i(1, "variable"),
    t(" = \" + "),
    rep(1),
    t(");"),
  }),
  
  -- Stream pipeline (stream)
  s({
    trig = "stream",
    name = "Stream pipeline",
    dscr = "Java stream pipeline",
  }, {
    i(1, "collection"),
    t(".stream()"),
    t({"", "\t."}),
    i(2, "filter(item -> condition)"),
    t({"", "\t."}),
    i(3, "map(item -> result)"),
    t({"", "\t."}),
    i(0, "collect(Collectors.toList())"),
  }),
  
  -- Optional handling (opt)
  s({
    trig = "opt",
    name = "Optional handling",
    dscr = "Handle Optional value",
  }, {
    i(1, "Optional<Type>"),
    t(" "),
    i(2, "optValue"),
    t(" = "),
    i(3, "getValue()"),
    t({";", ""}),
    rep(2),
    t(".ifPresent("),
    i(4, "value"),
    t(" -> {"),
    t({"", "\t"}),
    i(0),
    t({"", "});"})
  }),
  
  -- Assert equals (ase)
  s({
    trig = "ase",
    name = "Assert equals",
    dscr = "JUnit assertEquals",
  }, {
    t("assertEquals("),
    i(1, "expected"),
    t(", "),
    i(2, "actual"),
    i(0, ""),
    t(");")
  }),
  
  -- Assert true (ast)
  s({
    trig = "ast",
    name = "Assert true",
    dscr = "JUnit assertTrue",
  }, {
    t("assertTrue("),
    i(1, "condition"),
    i(0, ""),
    t(");")
  }),
}

return snippets
