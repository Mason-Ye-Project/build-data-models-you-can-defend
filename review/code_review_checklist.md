# Copperline model review checklist

## Meaning

- [ ] Every fact has a one-row-per sentence.
- [ ] The business process and intended consumer question are named.
- [ ] Every clock and as-of rule is explicit.
- [ ] Current-value and historical-value attributes are distinguished.

## Cardinality

- [ ] Source and model keys are tested independently.
- [ ] Each join has an expected match count.
- [ ] Multi-valued relationships use an explicit filter or attribution policy.
- [ ] Facts are aggregated to compatible grains before comparison.

## Measures

- [ ] Additive limits are documented.
- [ ] Ratios retain numerator and denominator.
- [ ] Null, zero, cancellation, and unknown policies are explicit.
- [ ] Source-side or external reconciliation is independent of the published mart.

## Change safety

- [ ] Schema changes identify history and restatement behavior.
- [ ] Baselines and counterexamples run before and after the change.
- [ ] Blast radius, rollback condition, and unresolved decisions are recorded.
- [ ] AI-generated code is treated as a proposal with executable evidence.

## Transfer

- [ ] Logical invariants are separated from physical platform choices.
- [ ] Unexecuted cloud examples are labeled illustrative.
- [ ] Informational key constraints are backed by executable integrity checks.
