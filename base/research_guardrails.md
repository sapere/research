# Research Guardrails

This document defines the quality standards, citation protocols, and verification rules for the Blueprint Genetics market opportunity research.

---

## Source Quality Hierarchy

Sources are ranked by authority tier. Prefer higher-tier sources for all factual claims:

| Tier | Source Types | Rating |
|---|---|---|
| 1 (Highest) | Government agencies (FDA, EMA, EC), regulatory bodies | HIGH |
| 2 | Academic institutions (.edu), peer-reviewed journals | HIGH |
| 3 | Established industry analysts (Grand View Research, MarketsandMarkets, Fortune Business Insights, Gartner) | HIGH |
| 4 | Recognized industry publications (GenomeWeb, BioSpace, MedTech Dive, Nature Biotechnology) | MEDIUM-HIGH |
| 5 | Major business news (Reuters, Bloomberg, WSJ) | MEDIUM |
| 6 | Company official sources (blueprintgenetics.com, investor relations, press releases) | MEDIUM |
| 7 | Professional networks (LinkedIn company pages), business databases (Crunchbase) | MEDIUM-LOW |
| 8 | Personal blogs, forums, social media | LOW |

---

## Forbidden Sources

Do NOT cite or rely on the following:

- Wikipedia (for factual claims — acceptable only for initial background)
- Social media posts (Twitter/X, Facebook, Reddit) unless from verified official accounts
- Anonymous forum posts
- Content farms or SEO-optimized aggregator sites
- Sources that cannot be verified via direct URL access
- AI-generated content without human editorial oversight

---

## Citation Format

All citations must use inline markdown links immediately following the claim:

```markdown
The global genetic testing market was valued at $XX billion in 2024 ([Grand View Research](URL)).
```

**Rules:**
- Citation placement: END of the sentence or clause, not at the beginning
- Multiple sources: `([Source A](URL1), [Source B](URL2))`
- Direct quotes: Use block quotes with citation: `> "Quote text" ([Source](URL))`
- Never use footnote-style citations (`[^1]`)
- Never fabricate URLs — cite only URLs successfully fetched in the session

---

## Hallucination Prevention Rules

**CRITICAL — Never fabricate:**

- URLs or DOIs (must be verified via fetch)
- Statistical figures (must be cited from source)
- Company names or product names (must be verified)
- Publication dates (must be visible on source page)
- Executive names or titles (must be verified)
- Market share percentages (must be sourced)

**If data cannot be found:**
- State explicitly: "No reliable data was found for [X]"
- Do NOT estimate or extrapolate without clear labeling: `[ESTIMATED]`

---

## Token Budget Guidelines

| Content Type | Target Length |
|---|---|
| Synthesis section (per task) | 200–500 words |
| Competitor profile | 150–300 words per company |
| Table entries | Concise; single-line cells preferred |
| Executive summary | 300–500 words |
| Strategic recommendation | 100–200 words per recommendation |

Avoid padding. Dense, evidence-backed content is preferred.

---

## Evidence Flags

Apply these flags in synthesis content when conditions are met:

| Flag | Condition |
|---|---|
| `[SINGLE_SOURCE]` | Claim supported by only one source |
| `[CONFLICTING: A says X, B says Y]` | Sources provide contradictory information |
| `[APPROXIMATE]` | Data is estimated or rounded |
| `[PARTIAL_ACCESS]` | Source was paywalled; only preview/abstract used |
| `[DATE_UNKNOWN]` | Publication date not visible |
| `[ANONYMOUS_AUTHOR]` | No named author could be identified |
| `[POTENTIAL_BIAS: reason]` | Source has sponsorship or advocacy affiliation |

---

## Source Verification Protocol

Before citing any source, the Research Worker must:

1. **Fetch the URL** and confirm HTTP 200 response
2. **Verify relevance** — content matches the claimed information
3. **Check publication date** — prefer sources from 2024-2026
4. **Assess authority** — apply source quality hierarchy
5. **Log the source** in `research_sources.md` with all metadata

---

## Conflicting Evidence Protocol

When sources provide conflicting information:

1. Document both positions in synthesis with explicit flag
2. Note which source appears more authoritative (by tier)
3. If possible, seek a third source for tiebreaker
4. Present the range of values for numerical conflicts (e.g., "Market size estimates range from $X to $Y billion")

---

## Domain Terminology

Define the following terms on first use in synthesis:

| Term | Definition |
|---|---|
| NGS | Next-Generation Sequencing — high-throughput DNA sequencing technology |
| WES | Whole Exome Sequencing — sequencing of protein-coding regions |
| WGS | Whole Genome Sequencing — complete genome analysis |
| VUS | Variant of Uncertain Significance — genetic variant with unclear clinical impact |
| LDT | Laboratory Developed Test — tests designed and validated in-house by a lab |
| IVDR | In Vitro Diagnostic Regulation — EU regulatory framework for diagnostic devices |
| CLIA | Clinical Laboratory Improvement Amendments — US regulatory standards for clinical labs |
| CAP | College of American Pathologists — laboratory accreditation body |
| TAT | Turnaround Time — time from sample receipt to result delivery |
| PGx | Pharmacogenomics — study of genetic influence on drug response |

---

## Output Quality Checklist

Before marking any task complete, verify:

- [ ] All factual claims have inline citations
- [ ] No URLs were fabricated (all were fetched successfully)
- [ ] Single-source claims are flagged
- [ ] Tables have header row and separator
- [ ] Terminology is defined on first use
- [ ] Section ends with relevance statement
- [ ] Content fits within token budget guidelines
- [ ] Sources are logged in research_sources.md