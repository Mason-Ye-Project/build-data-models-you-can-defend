# AI proposal review: replace the star with one wide table

## Prompt boundary

“Simplify the Copperline analytics model for a junior team. Produce one table for revenue, utilization, customer segment, equipment capability, and on-time returns. Minimize joins.”

The prompt intentionally omits grain, history, attribution, and clock requirements. It is a test of whether attractive implementation output can be accepted without those decisions.

## Proposal summary

The proposal joins rental headers, rental lines, current customers, equipment capabilities, and daily inventory into one wide relation. It recommends grouping by branch and day, then exposing sums and average rates.

## Human decision

Reject the proposal as a published model. Reuse only its suggested column-naming cleanup after independent review.

## Executable evidence

- Joining line revenue to multi-valued capabilities changes $1,175.00 to $2,250.00.
- Joining transaction and daily snapshot facts before compatible aggregation creates a many-to-many relationship.
- Joining current customer segment would relabel `R1001` as Enterprise instead of its event-time Commercial version.
- Averaging utilization or on-time percentages discards denominator weighting.

## Corrected design

Keep three facts at their declared grains, conformed dimensions, an effective-dated customer lookup, a weighted capability bridge for allocated reporting, and component-based metric contracts. Publish narrow marts only for stated access patterns.

## Remaining limitation

The local fixture does not prove production workload performance. A target platform may justify denormalized serving tables after the logical model reconciles and workload evidence is collected.
