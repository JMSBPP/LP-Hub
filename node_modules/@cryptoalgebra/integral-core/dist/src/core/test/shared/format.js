"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.formatPrice = exports.formatTokenAmount = void 0;
const decimal_js_1 = require("decimal.js");
function formatTokenAmount(num) {
    return new decimal_js_1.Decimal(num.toString()).dividedBy(new decimal_js_1.Decimal(10).pow(18)).toPrecision(5);
}
exports.formatTokenAmount = formatTokenAmount;
function formatPrice(price) {
    return new decimal_js_1.Decimal(price.toString()).dividedBy(new decimal_js_1.Decimal(2).pow(96)).pow(2).toPrecision(5);
}
exports.formatPrice = formatPrice;
