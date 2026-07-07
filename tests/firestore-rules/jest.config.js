const path = require("path");

/** @type {import('jest').Config} */
module.exports = {
  testEnvironment: "node",
  testMatch: ["**/*.test.ts"],
  moduleFileExtensions: ["ts", "js", "json"],
  transform: {
    "^.+\\.ts$": path.resolve(__dirname, "../../functions/node_modules/ts-jest"),
  },
};
