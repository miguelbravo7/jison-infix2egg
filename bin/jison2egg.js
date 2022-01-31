const fs = require('fs');
const input = fs.readFileSync(process.argv[2] || 'jison.we');
console.log(`Processing <${input}>`);
// const JISON = require("../grammar.js");
// var tree = JISON.parse(input);
var jison = require("jison");

var bnf = fs.readFileSync("lib/grammar.jison", "utf8");
var parser = new jison.Parser(bnf);
var tree = parser.parse(input);

const { topEnv } = require("@ull-esit-pl-1920/p7-t3-egg-2-miguel");
console.log(tree.evaluate(topEnv));