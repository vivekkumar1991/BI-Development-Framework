# Skill: drillthrough-navigation

**Domain:** SSRS · **Owner:** SSRS Agent
**Load when:** adding/editing actions: drillthrough, bookmarks, hyperlinks.

## Purpose

Configure `<Action>` navigation on a report item minimally and coherently.

## Steps

1. Choose the action type: `Drillthrough` (`ReportName` + `Parameters`), `Hyperlink`
   (`Hyperlink` expression), or `BookmarkLink` (`BookmarkLink` → an item's `Bookmark`).
2. For drillthrough, ensure the target report exists in the project and each passed
   parameter maps to a real target `ReportParameter` (name + value expression).
3. For bookmarks, ensure the referenced `Bookmark` is defined on a reachable item.
4. Keep the host item's other properties unchanged.

## Output

A minimal action patch with resolvable targets/parameters. Verify references via
[`impact-analysis`](impact-analysis.md) and [`validation`](validation.md).
