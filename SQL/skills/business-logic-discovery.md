# Skill: business-logic-discovery

**Domain:** SQL · **Owner:** SQL Agent
**Load when:** mode is REFERENCE_LOGIC.

## Purpose

Find where an existing, approved business rule is defined and reuse it — **never invent**.

## Steps

1. From the request, identify the named logic (e.g. "Active Customer").
2. Search the referenced report/RDL and known SQL objects for where it is implemented
   (dataset query `WHERE`/`CASE`, calculated field, SSRS expression, view, proc).
3. Extract the **exact** definition; note any parameters/filters it depends on.
4. If the logic exists in an **SSRS/VB expression**, translate to SQL **preserving semantics**
   precisely (null handling, comparisons, date logic).
5. If it **cannot be found**, stop and **ask for a reference or definition**.

## Output

The located logic (verbatim + a semantic note) for [`sql-generation`](sql-generation.md).
Pairs with [`report-reference-analysis`](report-reference-analysis.md).
