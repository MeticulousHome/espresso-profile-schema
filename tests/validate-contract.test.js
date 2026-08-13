import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const repositoryRoot = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "..",
);
const readJson = (fileName) =>
  JSON.parse(fs.readFileSync(path.join(repositoryRoot, fileName), "utf8"));

const schema = readJson("schema.json");
const example = readJson("example_profile.json");
const triggerSchema =
  schema.properties.stages.items.properties.exit_triggers.items;
const comparisonSchema = triggerSchema.properties.comparison;
const supportedComparisons = [">", "<", ">=", "<="];
const numericTriggerTypes = [
  "weight",
  "time",
  "pressure",
  "flow",
  "piston_position",
  "power",
];

const acceptsComparison = (comparison) =>
  comparison === undefined || comparisonSchema.enum.includes(comparison);

test("JSON documents parse", () => {
  assert.ok(schema);
  assert.ok(example);
});

test("comparison is optional and has the compatibility fallback", () => {
  assert.deepEqual(comparisonSchema.enum, supportedComparisons);
  assert.equal(comparisonSchema.default, ">=");
  assert.ok(!triggerSchema.required.includes("comparison"));
  assert.ok(acceptsComparison(undefined));
});

test("all numeric triggers accept every supported comparison without mutation", () => {
  for (const type of numericTriggerTypes) {
    assert.ok(triggerSchema.properties.type.enum.includes(type));

    for (const comparison of supportedComparisons) {
      const trigger = {
        type,
        value: 1,
        relative: false,
        comparison,
        unrelated: "preserve-me",
      };
      const beforeValidation = structuredClone(trigger);

      assert.ok(acceptsComparison(trigger.comparison));
      assert.deepEqual(trigger, beforeValidation);
    }

    const triggerWithoutComparison = { type, value: 1, relative: false };
    const beforeValidation = structuredClone(triggerWithoutComparison);

    assert.ok(acceptsComparison(triggerWithoutComparison.comparison));
    assert.deepEqual(triggerWithoutComparison, beforeValidation);
    assert.ok(!Object.hasOwn(triggerWithoutComparison, "comparison"));
  }
});

test("all numeric triggers reject unsupported comparisons", () => {
  for (const type of numericTriggerTypes) {
    for (const comparison of ["==", "!=", "=>", "=<", "greater"]) {
      const trigger = { type, value: 1, comparison };
      assert.ok(!acceptsComparison(trigger.comparison));
    }
  }
});

test("checking example comparisons does not rewrite the profile", () => {
  const beforeValidation = structuredClone(example);

  for (const stage of example.stages) {
    for (const trigger of stage.exit_triggers) {
      assert.ok(acceptsComparison(trigger.comparison));
    }
  }

  assert.deepEqual(example, beforeValidation);
});
