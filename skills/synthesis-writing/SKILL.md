---
name: synthesis-writing
description: Write structured research synthesis sections with inline citations, proper heading hierarchy, evidence tables, and cross-referenced findings following the research_synthesis.md format conventions.
user-invocable: false
disable-model-invocation: false
---

# Synthesis Writing Skill

Use this skill when writing or appending sections to `research_synthesis.md`. Every synthesis section must follow these conventions to ensure consistency, verifiability, and readability.

## Procedure

1. **Section Structure**
   - Start each section with a heading: `### X.Y Title (TASK-X.Y)`
   - Follow with a 1–2 sentence contextual introduction explaining why this section matters
   - Present findings in logical order: most important first, supporting details second
   - Group related findings under descriptive subheadings if the section exceeds 300 words

2. **Citation Format**
   - Use inline markdown links immediately after each claim: `([source title](URL))`
   - Place the citation at the END of the sentence or clause it supports — not at the beginning
   - Multiple citations for the same claim: `([source A](URL1), [source B](URL2))`
   - Every factual claim, statistic, or specific detail MUST have at least one citation
   - Opinions or interpretive statements should be clearly labeled as such

3. **Evidence Presentation**
   - Use **tables** for comparative data (e.g., feature comparisons, statistical breakdowns)
   - Use **prose** for narrative findings, explanations, and contextual analysis
   - Use **block quotes** (`>`) for direct quotes from sources (with citation)
   - Tables must have: header row, separator row, consistent column alignment
   - Prefer data density — avoid repeating the same information in both table and prose

4. **Evidence Flags**
   - If a claim is supported by only one source, append `[SINGLE_SOURCE]` after the citation
   - If sources conflict, use: `[CONFLICTING: Source A says X, Source B says Y]`
   - If data is estimated or approximate, use: `[APPROXIMATE]`
   - If a source was paywalled and only a preview was accessible: `[PARTIAL_ACCESS]`

5. **Claim Confidence Scoring**
   - For key claims (statistics, regulatory facts, competitive positioning), append a confidence tag: `[CONF: HIGH]`, `[CONF: MED]`, or `[CONF: LOW]`
   - **HIGH**: 2+ independent HIGH-quality sources agree, claim is specific and verifiable
   - **MED**: Single HIGH-quality source, or 2+ MEDIUM-quality sources agree
   - **LOW**: Single MEDIUM/LOW source, conflicting sources unresolved, or partial access only
   - Apply to the top 3-5 most consequential claims per section — not every sentence
   - In evidence tables, add a Confidence column when the table has quantitative data

6. **Terminology**
   - Define domain-specific terms, acronyms, and jargon on first use
   - Format: "Term in bold followed by explanation" — e.g., **GOAP** (Goal-Oriented Action Planning) is a...
   - After first definition, use the term freely without re-explaining
   - If a term appears for the first time in a later section, re-define it there

7. **Relevance Statement**
   - End each section with 1–2 sentences connecting the findings back to the research objective
   - Format: "These findings are relevant to [objective] because [reason]."
   - This helps the narrator summary generator understand the significance of each section

8. **Length and Scope**
   - Target 200–500 words per task section unless the task explicitly specifies more
   - Do not pad sections with filler content — prefer concise, dense writing
   - If insufficient data was found, state this explicitly rather than stretching thin findings
   - If the section grows beyond 500 words, verify every additional sentence adds new information
