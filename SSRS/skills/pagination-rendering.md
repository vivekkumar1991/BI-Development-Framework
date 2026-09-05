# Skill: pagination-rendering

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** adjusting page breaks, page size/margins, or render performance.

## Purpose

Tune pagination and rendering with minimal, targeted edits.

## Steps

1. Page setup lives in `<Page>` (`PageHeight`, `PageWidth`, margins) and group/rectangle
   `PageBreak` (`BreakLocation`), and `KeepTogether`/`KeepWithGroup` where supported.
2. For wide-report overflow, check the body width vs page width minus margins.
3. For slow rendering: reduce per-row subreports, heavy expressions, and unnecessary
   grouping; prefer dataset-side aggregation (hand heavy queries to the SQL Agent).
4. Change only the relevant page/break properties; leave layout otherwise intact.

## Output

A minimal pagination/rendering patch. Final render/perf confirmation is a developer/SSDT step;
structural checks via [`validation`](validation.md).
